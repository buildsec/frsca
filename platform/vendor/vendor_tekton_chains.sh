#!/bin/bash

set -euo pipefail

# NOTE: This is based on the release validation process for tekton pipelines: https://github.com/tektoncd/pipeline/releases
RELEASE_FILE=https://storage.googleapis.com/tekton-releases/chains/previous/v0.5.0/release.yaml
REKOR_UUID=3a62d47dcbe0727513ac2e2dcc3a41bfd413ebc128bb661ed4f115d4db83200f

TEKTON_DIR=tekton/chains

# Obtains the list of images with sha from the attestation
REKOR_ATTESTATION_IMAGES=$(rekor-cli get --uuid "$REKOR_UUID" --format json | jq -r .Attestation | base64 --decode | jq -r '.subject[]|.name + ":v0.5.0@sha256:" + .digest.sha256')

# Download the release file
curl "$RELEASE_FILE" > $TEKTON_DIR/release.yaml

# For each image in the attestation, match it to the release file
for image in $REKOR_ATTESTATION_IMAGES; do 
  printf $image; grep -q $image $TEKTON_DIR/release.yaml && echo " ===> ok" || (
      echo " ===> no match";
      exit 1
  )
done
