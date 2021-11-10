#!/bin/bash
set -xeuo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)
KYVERNO_INSTALL_DIR=${GIT_ROOT}/platform/vendor/kyverno/release
KYVERNO_RESOURCE_DIR=${GIT_ROOT}/resources/kyverno/admission-control-policy

# Define variables.
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_RESET_ALL='\033[0m'

# Wait until pods are ready.
# $1: namespace, $2: app label
wait_for_pods () {
  echo -e "${C_YELLOW}Waiting: $2 pods in $1...${C_RESET_ALL}"
  kubectl wait --timeout=5m --for=condition=ready pods -l app=$2 -n $1
}

# Update below if you have a different config.json you want to use.
DOCKER_CONFIG_JSON=$HOME/.docker/config.json

# Kyverno setup from the getting started tutorial:
#   https://nirmata.com/2021/08/12/kubernetes-supply-chain-policy-management-with-cosign-and-kyverno/
#   Installation: https://kyverno.io/docs/installation/

# Create secrets for kaniko and kubernetes image pull
kubectl create namespace kyverno --dry-run=client -o yaml | kubectl apply -f -

# TODO: This should jsut be the normal secret if the kaniko task is updated to correctly use the docker config secret instead of requiring it to be hardcoded as config.json
kubectl create secret generic secret-dockerconfigjson --type=opaque --from-file=config.json=$DOCKER_CONFIG_JSON --dry-run=client -o yaml | kubectl apply -f -

# NOTE: Pull secret needs to exist in both kyverno namespace as well as the tekton task namespace (default in this case)
kubectl create secret generic regcred --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson=$DOCKER_CONFIG_JSON -n kyverno  --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic regcred --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson=$DOCKER_CONFIG_JSON --dry-run=client -o yaml | kubectl apply -f -

# Assumes helm already installed by previous scripts
kubectl apply -f $KYVERNO_INSTALL_DIR/release.yaml
# Wait for kyverno deployment to complete
wait_for_pods kyverno kyverno

kubectl patch deployment \
  -n kyverno \
  kyverno \
  --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--webhooktimeout=15"}]'

kubectl patch deployment \
  -n kyverno \
  kyverno \
  --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--imagePullSecrets=regcred"}]'

kubectl apply -f $KYVERNO_RESOURCE_DIR
