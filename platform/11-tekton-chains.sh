#!/bin/bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Setup tekton Chains and install Cosign if needed.
#
# Environment variables:
#   TKN_CHAINS_FORMAT: defines an alternative format to store provenance
#     information.
#     Possibles values: `intoto`. Any other value would simply use the default
#     behaviour.

: ${TKN_CHAINS_FORMAT:=""}

# Install Chains.
kubectl apply --filename $GIT_ROOT/platform/vendor/tekton/chains/release.yaml

# Patch chains to generate in-toto provenance.
case "${TKN_CHAINS_FORMAT}" in
  intoto)
    kubectl patch \
      configmap chains-config \
      -n tekton-chains \
      -p='{"data":{"artifacts.taskrun.format": "in-toto"}}'
    ;;
  *)
    ;;
esac

kubectl patch \
      configmap chains-config \
      -n tekton-chains \
      -p='{"data": {"artifacts.taskrun.storage": "oci", "artifacts.taskrun.format": "tekton-provenance"}}'

# Install Cosign if needed.
if ! cosign version; then
  ./12-cosign-installer.sh
fi
