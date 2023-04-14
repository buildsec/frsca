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

GIT_ROOT=$(git rev-parse --show-toplevel)

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Setup Policy Controller.
echo -e "${C_GREEN}Setup Policy Controller..${C_RESET_ALL}"

kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -

# create a policy to check signatures on ttl.sh and minikube embedded registry
pushd "${GIT_ROOT}/platform/components/policy-controller"
cue cmd -t "repository=${REPO}" -t "key=${USERPUBKEY}" apply | kubectl apply -f -
popd

# update namespace to run the policy
kubectl label --overwrite namespace prod policy.sigstore.dev/include=true
