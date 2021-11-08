#!/bin/bash
set -euo pipefail

# Define variables.
GIT_ROOT=$(git rev-parse --show-toplevel)

# Install the buildpacks pipelinerun.
kubectl apply -f ${GIT_ROOT}/examples/buildpacks/pipeline-pvc.yaml
kubectl create -f ${GIT_ROOT}/examples/buildpacks/pipelinerun-buildpacks.yaml
tkn pipelinerun describe --last
