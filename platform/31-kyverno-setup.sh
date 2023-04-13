#!/usr/bin/env bash
set -euo pipefail

if kubectl -n vault get configmap frsca-certs >/dev/null 2>&1; then
  USERPUBKEY=$(kubectl -n vault get configmap frsca-certs -o jsonpath='{.data.frsca\.pem}')
else
  USERPUBKEY=$(cosign public-key --key k8s://tekton-chains/signing-secrets)
fi
REPO=${REGISTRY:-ttl.sh}
if [ "${REPO}" = "registry.registry" ]; then
  REPO="host.minikube.internal:5443"
fi
REPO="${REPO}/*"

GIT_ROOT=$(git rev-parse --show-toplevel)

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Update below if you have a different config.json you want to use.
DOCKER_CONFIG_JSON=$HOME/.docker/config.json
if [ ! -f "${DOCKER_CONFIG_JSON}" ]; then
  DOCKER_CONFIG_JSON="${GIT_ROOT}/resources/docker-config-empty.json"
fi

# Kyverno setup from the getting started tutorial:
#   https://nirmata.com/2021/08/12/kubernetes-supply-chain-policy-management-with-cosign-and-kyverno/
#   Installation: https://kyverno.io/docs/installation/

echo -e "${C_GREEN}Creating docker config secrets...${C_RESET_ALL}"
# TODO: This should just be the normal secret if the kaniko task is updated to correctly use the docker config secret instead of requiring it to be hardcoded as config.json
kubectl create secret generic secret-dockerconfigjson --type=opaque --from-file=config.json="$DOCKER_CONFIG_JSON" --dry-run=client -o yaml | kubectl apply -f -

# NOTE: Pull secret needs to exist in both kyverno namespace as well as the tekton task namespace (default in this case)
kubectl create secret generic regcred --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson="$DOCKER_CONFIG_JSON" -n kyverno  --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic regcred --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson="$DOCKER_CONFIG_JSON" --dry-run=client -o yaml | kubectl apply -f -

echo -e "${C_GREEN}Patching Kyverno deployment...${C_RESET_ALL}"
kubectl patch \
  deployment kyverno \
  -n kyverno \
  --type json --patch-file "${GIT_ROOT}"/platform/components/kyverno/patch_container_args.json
kubectl patch \
  deployment kyverno \
  -n kyverno \
  --patch-file "${GIT_ROOT}"/platform/components/kyverno/patch_ca_certs.json
kubectl rollout status -n kyverno deployment/kyverno

echo -e "${C_GREEN}Creating verify-image admission control policy...${C_RESET_ALL}"
pushd "$GIT_ROOT"/resources/kyverno/admission-control-policy
cue cmd -t repo="$REPO" -t key="$USERPUBKEY" apply | kubectl apply -f -
popd
