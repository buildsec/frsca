#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)
KYVERNO_INSTALL_DIR=${GIT_ROOT}/platform/vendor/kyverno/release

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Kyverno setup from the getting started tutorial:
#   https://nirmata.com/2021/08/12/kubernetes-supply-chain-policy-management-with-cosign-and-kyverno/
#   Installation: https://kyverno.io/docs/installation/

echo -e "${C_GREEN}Installing Kyverno...${C_RESET_ALL}"
kubectl apply --server-side=true --force-conflicts -f "$KYVERNO_INSTALL_DIR"/install.yaml
# Wait for kyverno deployment to complete
kubectl rollout status -n kyverno deployment/kyverno
