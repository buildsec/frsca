#!/bin/bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)
KYVERNO_INSTALL_DIR=${GIT_ROOT}/platform/vendor/kyverno/release
KYVERNO_RESOURCE_DIR=${GIT_ROOT}/resources/kyverno/admission-control-policy

### HACK to work around the latest version of Kyverno not having the updates Jim made for us with configmaps. 
### Once offically released. We will go back to using the versioned release.
KYVERNO_URL="https://raw.githubusercontent.com/kyverno/kyverno/main/config/install.yaml"

# # Define variables.
# KYVERNO_TAG_RELEASE=v1.5.1
# KYVERNO_URL="https://raw.githubusercontent.com/kyverno/kyverno/$KYVERNO_TAG_RELEASE/definitions/release/install.yaml"
# COSIGN_REPOSITORY=ghcr.io/kyverno/signatures
# PUBKEY=https://raw.githubusercontent.com/kyverno/kyverno/$KYVERNO_TAG_RELEASE/cosign.pub

# KYVERNO_LATEST=`COSIGN_REPOSITORY=$COSIGN_REPOSITORY cosign verify --key $PUBKEY ghcr.io/kyverno/kyverno:$KYVERNO_TAG_RELEASE`
# KYVERNO_LATEST_STATUS=$?
# KYVERNOPRE_LATEST=`COSIGN_REPOSITORY=$COSIGN_REPOSITORY cosign verify --key $PUBKEY ghcr.io/kyverno/kyvernopre:$KYVERNO_TAG_RELEASE`
# KYVERNOPRE_LATEST_STATUS=$?
# KYVERNOCLI_LATEST=`COSIGN_REPOSITORY=$COSIGN_REPOSITORY cosign verify --key $PUBKEY ghcr.io/kyverno/kyverno-cli:$KYVERNO_TAG_RELEASE`
# KYVERNOCLI_LATEST_STATUS=$?

# if [ $KYVERNO_LATEST_STATUS -eq 0 ] && [ $KYVERNOPRE_LATEST_STATUS -eq 0 ] && [ $KYVERNOCLI_LATEST_STATUS -eq 0 ] ; then
#   # Download the release file
  curl "$KYVERNO_URL" > $KYVERNO_INSTALL_DIR/release.yaml
#fi
