#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Setup Gitea.
echo -e "${C_GREEN}Setting up Gitea...${C_RESET_ALL}"
kubectl create namespace gitea --dry-run=client --output=yaml | kubectl apply -f -

helm upgrade --install gitea "${GIT_ROOT}/platform/vendor/gitea/chart" \
  --values "${GIT_ROOT}/platform/components/gitea/values.yaml" \
  --namespace gitea --wait

kubectl rollout status -n gitea statefulset/gitea
