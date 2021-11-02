#!/bin/bash
set -euo pipefail

# Install the buildpacks pipelinerun.
kubectl apply -f pipelinerun-buildpacks.yaml
tkn pipelinerun describe --last
