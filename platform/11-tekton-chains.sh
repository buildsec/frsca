#!/bin/bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Setup tekton Chains

# Install Chains.
kubectl apply --filename "$GIT_ROOT"/platform/vendor/tekton/chains/release.yaml
kubectl rollout status -n tekton-chains deployment/tekton-chains-controller

# Patch chains to generate in-toto provenance and store output in OCI
kubectl patch \
      configmap chains-config \
      -n tekton-chains \
      --patch-file "$GIT_ROOT"/platform/components/tekton/chains/patch_config_oci.yaml
kubectl rollout status -n tekton-chains deployment/tekton-chains-controller
