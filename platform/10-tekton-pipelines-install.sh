#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Setup Tekton.
echo -e "${C_GREEN}Installing Tekton CD...${C_RESET_ALL}"
kubectl apply --filename "$GIT_ROOT"/platform/vendor/tekton/pipeline/release.yaml
kubectl apply --filename "$GIT_ROOT"/platform/vendor/tekton/triggers/release.yaml
kubectl apply --filename "$GIT_ROOT"/platform/vendor/tekton/triggers/interceptors.yaml

kubectl apply --filename "${GIT_ROOT}/platform/components/tekton/triggers/rbac.yaml"

# Wait for tekton deployments to finish
for deployment in tekton-pipelines-webhook tekton-pipelines-controller tekton-triggers-controller tekton-triggers-core-interceptors tekton-triggers-webhook; do
  kubectl rollout status -n tekton-pipelines "deployment/${deployment}"
done
