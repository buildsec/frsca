#!/bin/bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Define variables.
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_RESET_ALL='\033[0m'

# Wait until pods are ready.
# $1: app label
wait_for_pods () {
  while [[ $(kubectl get pods --namespace tekton-pipelines -l app="$1" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
  echo -e "${C_YELLOW}Waiting for $1 pods...${C_RESET_ALL}"
  sleep 1
done
}

# Setup Tekton.
echo -e "${C_GREEN}Setting up Tekton CD...${C_RESET_ALL}"
kubectl apply --filename "$GIT_ROOT"/platform/vendor/tekton/pipeline/release.yaml
wait_for_pods tekton-pipelines-controller

# Setup the Dashboard.
#   Use `kubectl proxy --port=8080` and then
#   http://localhost:8080/api/v1/namespaces/tekton-pipelines/services/tekton-dashboard:http/proxy/
#   to access it.
kubectl apply --filename https://github.com/tektoncd/dashboard/releases/latest/download/tekton-dashboard-release.yaml
wait_for_pods tekton-dashboard

# Wait for tekton pipelines configuration webhook to come up
wait_for_pods tekton-pipelines-webhook
