#!/bin/bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Setup Tekton.
echo -e "${C_GREEN}Setting up Tekton CD...${C_RESET_ALL}"
kubectl apply --filename "$GIT_ROOT"/platform/vendor/tekton/pipeline/release.yaml
kubectl rollout status -n tekton-pipelines deployment/tekton-pipelines-controller

# Setup the Dashboard.
#   Use `kubectl proxy --port=8080` and then
#   http://localhost:8080/api/v1/namespaces/tekton-pipelines/services/tekton-dashboard:http/proxy/
#   to access it.
kubectl apply --filename https://github.com/tektoncd/dashboard/releases/latest/download/tekton-dashboard-release.yaml
kubectl rollout status -n tekton-pipelines deployment/tekton-dashboard

# Wait for tekton pipelines configuration webhook to come up
kubectl rollout status -n tekton-pipelines deployment/tekton-pipelines-webhook
