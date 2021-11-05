#!/bin/bash
set -euo pipefail

# Install Cosign if needed.
if ! type cosign; then
  COSIGN_BIN=cosign
  COSIGN_OS=$(uname | tr '[:upper:]' '[:lower:]')
  COSIGN_ARCH=$(uname -m)
  COSIGN_VERSION=v1.2.1
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
