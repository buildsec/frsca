#!/bin/bash
set -euo pipefail

USERPUBKEY="-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEhyQCx0E9wQWSFI9ULGwy3BuRklnt
IqozONbbdbqz11hlRJy9c7SG+hdcFl9jE9uE/dwtuwU2MqU9T/cN0YkWww==
-----END PUBLIC KEY-----"

GIT_ROOT=$(git rev-parse --show-toplevel)
KYVERNO_INSTALL_DIR=${GIT_ROOT}/platform/vendor/kyverno/release
KYVERNO_RESOURCE_DIR=${GIT_ROOT}/resources/kyverno/admission-control-policy

# Define variables.
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RESET_ALL='\033[0m'

# Wait until pods are ready.
# $1: namespace, $2: app label
wait_for_pods() {
	sleep 1
	echo -e "${C_YELLOW}Waiting: $2 pods in $1...${C_RESET_ALL}"
	kubectl wait --timeout=5m --for=condition=ready pods -l app="$2" -n "$1"
}

# Update below if you have a different config.json you want to use.
DOCKER_CONFIG_JSON=$HOME/.docker/config.json

# Kyverno setup from the getting started tutorial:
#   https://nirmata.com/2021/08/12/kubernetes-supply-chain-policy-management-with-cosign-and-kyverno/
#   Installation: https://kyverno.io/docs/installation/

echo -e "${C_GREEN}Installing Kyverno...${C_RESET_ALL}"
kubectl apply -f "$KYVERNO_INSTALL_DIR"/release.yaml
# Wait for kyverno deployment to complete
wait_for_pods kyverno kyverno

echo -e "${C_GREEN}Creating docker config secrets...${C_RESET_ALL}"
# TODO: This should just be the normal secret if the kaniko task is updated to correctly use the docker config secret instead of requiring it to be hardcoded as config.json
kubectl create secret generic secret-dockerconfigjson --type=opaque --from-file=config.json="$DOCKER_CONFIG_JSON" --dry-run=client -o yaml | kubectl apply -f -

# NOTE: Pull secret needs to exist in both kyverno namespace as well as the tekton task namespace (default in this case)
kubectl create secret generic regcred --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson="$DOCKER_CONFIG_JSON" -n kyverno --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic regcred --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson="$DOCKER_CONFIG_JSON" --dry-run=client -o yaml | kubectl apply -f -

### HACK - setting to Jim's personal image repo for kyverno to resolve
### failed calling webhook "mutate.kyverno.svc-fail" error. Once this image
### is offically released, this will be removed.
kubectl set image -n kyverno deploy/kyverno kyverno=ghcr.io/jimbugwadia/kyverno:v1.5.2-rc3-311-g4835157c

echo -e "${C_GREEN}Patching Kyverno deployment...${C_RESET_ALL}"
kubectl patch \
	deployment kyverno \
	-n kyverno \
	--type json --patch-file "${GIT_ROOT}"/platform/components/kyverno/patch_container_args.json

echo -e "${C_GREEN}Creating verify-image admission control policy...${C_RESET_ALL}"
cue export "$KYVERNO_RESOURCE_DIR"/admission-control-verify-image-resources.cue -e template -t key="$USERPUBKEY" --out yaml >"$KYVERNO_RESOURCE_DIR"/admission-control-verify-image-resources.yaml
kubectl apply -f "$KYVERNO_RESOURCE_DIR"
