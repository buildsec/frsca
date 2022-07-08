#!/bin/bash
set -euo pipefail

# Define variables.
GIT_ROOT=$(git rev-parse --show-toplevel)
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Install the buildpacks pipelinerun.
echo -e "${C_GREEN}Creating a bad trufflehog pipelinerun.${C_RESET_ALL}"
pushd "${GIT_ROOT}"/examples/trufflehog
cue cmd apply | kubectl apply -f -
cue cmd create | kubectl create -f -
popd
tkn pipelinerun describe --last
