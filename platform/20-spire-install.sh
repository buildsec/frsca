#!/usr/bin/env bash
set -exuo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Install Spire.
 echo -e "${C_GREEN}Installing Spire..${C_RESET_ALL}"

kubectl create namespace spire --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install -n spire spire-crds "${GIT_ROOT}/platform/vendor/spire/crd" --wait
helm upgrade --install -n spire spire "${GIT_ROOT}/platform/vendor/spire/server" \
  --values "${GIT_ROOT}/platform/components/spire/values.yaml" --wait

kubectl rollout status -n spire statefulset/spire-server
kubectl rollout status -n spire daemonset/spire-agent
kubectl rollout status -n spire daemonset/spire-spiffe-csi-driver
kubectl rollout status -n spire deploy/spire-spiffe-oidc-discovery-provider

