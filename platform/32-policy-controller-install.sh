#!/usr/bin/env bash
set -exuo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Install Policy Controller.
echo -e "${C_GREEN}Installing Policy Controller..${C_RESET_ALL}"

kubectl create namespace cosign-system --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install policy-controller "${GIT_ROOT}/platform/vendor/sigstore/policy-controller" \
  --values "${GIT_ROOT}/platform/components/policy-controller/values.yaml" \
  --namespace cosign-system --wait

kubectl rollout status -n cosign-system deployment/policy-controller-webhook
kubectl rollout status -n cosign-system deployment/policy-controller-policy-webhook
