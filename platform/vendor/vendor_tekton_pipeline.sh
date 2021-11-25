#!/bin/bash

set -euo pipefail

# NOTE: This is based on the release validation process for tekton pipelines: https://github.com/tektoncd/pipeline/releases
RELEASE_FILE=https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.29.0/release.yaml
REKOR_UUID=8ba5dcc45b9fad4d879a8b6815cdaa85fdee1d9fc24cf8811f103d537c602908

TEKTON_DIR=tekton/pipeline

# Obtains the list of images with sha from the attestation
REKOR_ATTESTATION_IMAGES=$(rekor-cli get --uuid "$REKOR_UUID" --format json | jq -r .Attestation | base64 --decode | jq -r '.subject[]|.name + ":v0.29.0@sha256:" + .digest.sha256')

# Download the release file
curl "$RELEASE_FILE" >$TEKTON_DIR/release.yaml

# For each image in the attestation, match it to the release file
for image in $REKOR_ATTESTATION_IMAGES; do
	printf "%s" "$image"

	if grep -q "$image" $TEKTON_DIR/release.yaml; then
		echo " ===> ok"
	else
		echo " ===> no match"
		exit 1
	fi

done
