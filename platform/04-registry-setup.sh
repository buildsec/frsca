#!/bin/bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Setup Registry.
echo -e "${C_GREEN}Setting up Registry...${C_RESET_ALL}"
kubectl create namespace registry --dry-run=client --output=yaml | kubectl apply -f -
kubectl apply -n registry --filename "$GIT_ROOT"/platform/components/registry/registry.yaml
kubectl rollout status -n registry statefulset/registry
kubectl rollout status -n registry daemonset/registry-proxy
