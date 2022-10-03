#!/usr/bin/env bash
set -euo pipefail

# Bootstrap CUE so it can be used as the configuration source

# Detect the platform.
PLATFORM=$(uname | tr '[:upper:]' '[:lower:]')

CUE_VERSION=v0.4.3
CUE_ARCH=$(uname -m | sed -e 's/x86_64/amd64/')
CUE_FILE_NAME="cue_${CUE_VERSION}_${PLATFORM}_${CUE_ARCH}.tar.gz"
CUE_URL="https://github.com/cue-lang/cue/releases/download/${CUE_VERSION}"
CUE_CHECKSUMS=checksums.txt

INSTALL_DIR=/usr/local/bin
CHECKSUM_FILE=download_checksum.txt

# Define variables.
C_GREEN='\033[32m'
C_RED='\033[31m'
C_RESET_ALL='\033[0m'

# Install CUE if needed
echo -e "${C_GREEN}Installing CUE if needed...${C_RESET_ALL}"
case "${PLATFORM}" in

  darwin)
    cue version || brew install cue-lang/tap/cue
    ;;

  linux)
    cue version || (
      echo -e "${C_GREEN}cue not found, installing: ${CUE_URL}/${CUE_FILE_NAME}${C_RESET_ALL}"
      TMP=$(mktemp -d)
      pushd "$TMP"
      curl -LO "${CUE_URL}/${CUE_FILE_NAME}"
      curl -LO "${CUE_URL}/${CUE_CHECKSUMS}"
      grep "$CUE_FILE_NAME" "$CUE_CHECKSUMS" | grep -v sbom > "$CHECKSUM_FILE"
      sha256sum -c "$CHECKSUM_FILE"
      tar -xzf "$CUE_FILE_NAME"
      sudo install cue "$INSTALL_DIR/cue"
      rm "${CUE_CHECKSUMS}"
      rm "${CUE_FILE_NAME}"
      rm "${CHECKSUM_FILE}"
      rm -rf doc LICENSE README.md cue
      popd
      rmdir "$TMP"
    )
    ;;
  *)
    echo -e "${C_RED}The ${PLATFORM} platform is unimplemented or unsupported.${C_RESET_ALL}"
    exit 1
    ;;

esac
