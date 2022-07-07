#!/bin/bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Setup tekton Chains

# Install Chains.
kubectl apply --filename "$GIT_ROOT"/platform/vendor/tekton/chains/release.yaml || true
kubectl rollout status -n tekton-chains deployment/tekton-chains-controller

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

kubectl rollout status -n tekton-chains deployment/tekton-chains-controller
