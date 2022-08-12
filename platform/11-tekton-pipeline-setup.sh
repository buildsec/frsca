#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Setup Tekton.
echo -e "${C_GREEN}Setting up Tekton CD...${C_RESET_ALL}"

ca_cert="${GIT_ROOT}/platform/certs/ca/ca.pem"
# TODO: at most only one of these is actually needed
kubectl -n tekton-pipelines create configmap config-registry-cert \
  --from-file=cert="${ca_cert}" \
  --dry-run=client -o=yaml | kubectl apply -f -
kubectl patch \
      deployment tekton-pipelines-controller \
      -n tekton-pipelines \
      --patch-file "$GIT_ROOT"/platform/components/tekton/pipelines/patch_ca_certs.json
kubectl -n tekton-pipelines delete pod -l app=tekton-pipelines-controller

kubectl rollout status -n tekton-pipelines deployment/tekton-pipelines-controller

