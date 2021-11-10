#!/bin/bash
set -euo pipefail

USERPUBKEY="-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEhyQCx0E9wQWSFI9ULGwy3BuRklnt
IqozONbbdbqz11hlRJy9c7SG+hdcFl9jE9uE/dwtuwU2MqU9T/cN0YkWww==
-----END PUBLIC KEY-----"

GIT_ROOT=$(git rev-parse --show-toplevel)
KYVERNO_DIR=${GIT_ROOT}/platform/vendor/kyverno/release

# Define variables.
KYVERNO_TAG_RELEASE=v1.5.1
KYVERNO_URL="https://raw.githubusercontent.com/kyverno/kyverno/$KYVERNO_TAG_RELEASE/definitions/release/install.yaml"
COSIGN_REPOSITORY=ghcr.io/kyverno/signatures
PUBKEY=https://raw.githubusercontent.com/kyverno/kyverno/$KYVERNO_TAG_RELEASE/cosign.pub

KYVERNO_LATEST=`COSIGN_REPOSITORY=$COSIGN_REPOSITORY cosign verify --key $PUBKEY ghcr.io/kyverno/kyverno:$KYVERNO_TAG_RELEASE`
KYVERNO_LATEST_STATUS=$?
KYVERNOPRE_LATEST=`COSIGN_REPOSITORY=$COSIGN_REPOSITORY cosign verify --key $PUBKEY ghcr.io/kyverno/kyvernopre:$KYVERNO_TAG_RELEASE`
KYVERNOPRE_LATEST_STATUS=$?
KYVERNOCLI_LATEST=`COSIGN_REPOSITORY=$COSIGN_REPOSITORY cosign verify --key $PUBKEY ghcr.io/kyverno/kyverno-cli:$KYVERNO_TAG_RELEASE`
KYVERNOCLI_LATEST_STATUS=$?

if [ $KYVERNO_LATEST_STATUS -eq 0 ] && [ $KYVERNOPRE_LATEST_STATUS -eq 0 ] && [ $KYVERNOCLI_LATEST_STATUS -eq 0 ] ; then
  # Download the release file
  curl "$KYVERNO_URL" > $KYVERNO_DIR/release.yaml
  cue export $KYVERNO_DIR/admission-control-verify-image-resources.cue -e template -t key="$USERPUBKEY" --out yaml > $KYVERNO_DIR/admission-control-verify-image-resources.yaml
fi
