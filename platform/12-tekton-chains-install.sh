#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Install Chains.
echo -e "${C_GREEN}Installing Tekton Chains...${C_RESET_ALL}"

kubectl apply --filename "$GIT_ROOT"/platform/vendor/tekton/chains/release.yaml || true
kubectl rollout status -n tekton-chains deployment/tekton-chains-controller
