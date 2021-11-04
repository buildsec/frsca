#!/bin/bash
set -euo pipefail

# Define variables.
TOP=$(git root)

# Install the buildpacks pipelinerun.
kubectl apply -f ${TOP}/resources/tekton/examples/buildpacks/pipelinerun-buildpacks.yaml
tkn pipelinerun describe --last
