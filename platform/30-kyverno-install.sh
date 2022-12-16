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

echo -e "${C_GREEN}Delete Kyverno if already installed...${C_RESET_ALL}"
kubectl delete -f "$KYVERNO_INSTALL_DIR"/install.yaml || true

echo -e "${C_GREEN}Installing Kyverno...${C_RESET_ALL}"
kubectl create -f "$KYVERNO_INSTALL_DIR"/install.yaml
# Wait for kyverno deployment to complete
kubectl rollout status -n kyverno deployment/kyverno
