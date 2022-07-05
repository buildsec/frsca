#!/bin/bash
set -exuo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Setup tetragon.
echo -e "${C_GREEN}Setting up Tetragon...${C_RESET_ALL}"
helm upgrade --install tetragon "${GIT_ROOT}/platform/vendor/tetragon/chart" \
  --values "${GIT_ROOT}/platform/components/tetragon/values.yaml" \
  --namespace kube-system --wait

kubectl rollout status -n kube-system daemonset/tetragon

echo -e "${C_GREEN}Enable tracing policies for Tetragon...${C_RESET_ALL}"
kubectl apply -f "${GIT_ROOT}/platform/vendor/tetragon/tracingpolicy/v0.8.0/sys_write_follow_fd_prefix.yaml"
kubectl apply -f "${GIT_ROOT}/platform/vendor/tetragon/tracingpolicy/v0.8.0/tcp-connect.yaml"
