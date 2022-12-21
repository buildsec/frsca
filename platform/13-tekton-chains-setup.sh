#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Setup tekton Chains
echo -e "${C_GREEN}Setting up Tekton Chains...${C_RESET_ALL}"

# Patch chains to generate in-toto provenance and store output in OCI
kubectl patch \
      configmap chains-config \
      -n tekton-chains \
      --patch-file "$GIT_ROOT"/platform/components/tekton/chains/patch_config_oci.yaml

kubectl patch \
      configmap chains-config \
      -n tekton-chains \
      --patch-file "$GIT_ROOT"/platform/components/tekton/chains/patch_config_kms.yaml

kubectl patch \
      deployment tekton-chains-controller \
      -n tekton-chains \
      --patch-file "$GIT_ROOT"/platform/components/tekton/chains/patch_spire.json

kubectl patch \
      deployment tekton-chains-controller \
      -n tekton-chains \
      --patch-file "$GIT_ROOT"/platform/components/tekton/chains/patch_ca_certs.json

# restart tekton chains controller for patched configmap
kubectl rollout restart -n tekton-chains deployment/tekton-chains-controller

kubectl rollout status -n tekton-chains deployment/tekton-chains-controller
