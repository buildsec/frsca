#!/bin/bash
set -euo pipefail

# Setup tekton Chains and install Cosign if needed.
#
# Environment variables:
#   TKN_CHAINS_FORMAT: defines an alternative format to store provenance
#     information.
#     Possibles values: `intoto`. Any other value would simply use the default
#     behaviour.

: ${TKN_CHAINS_FORMAT:=""}

# Install Chains.
kubectl apply --filename https://storage.googleapis.com/tekton-releases/chains/latest/release.yaml

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

# Install Cosign if needed.
if ! cosign version; then
  COSIGN_BIN=cosign
  COSIGN_OS=$(uname | tr '[:upper:]' '[:lower:]')
  COSIGN_ARCH=$(uname -m)
  COSIGN_VERSION=v1.0.0
  COSIGN_RELEASE_URL="https://github.com/sigstore/${COSIGN_BIN}/releases/download/${COSIGN_VERSION}"
  COSIGN_CHECKSUMS="cosign_checksums.txt"
  COSIGN_ASSET="${COSIGN_BIN}-${COSIGN_OS}-${COSIGN_ARCH}"
  COSIGN_TMP_DIR=$(mktemp -d)
  cd "${COSIGN_TMP_DIR}"
  curl -sLO "${COSIGN_RELEASE_URL}/${COSIGN_ASSET}"
  curl -sLO "${COSIGN_RELEASE_URL}/${COSIGN_ASSET}.sig"
  curl -sLO "${COSIGN_RELEASE_URL}/${COSIGN_CHECKSUMS}"
  sha256sum --ignore-missing -c "${COSIGN_CHECKSUMS}"
  chmod a+x "${COSIGN_ASSET}"
  cp "${COSIGN_ASSET}" "/opt/local/bin/${COSIGN_BIN}"
  cd -
fi
