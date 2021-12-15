#!/bin/bash
set -euo pipefail

# Define variables.
GIT_ROOT=$(git rev-parse --show-toplevel)
DEFAULT_REPOSITORY=$(xxd -l 16 -c 16 -p < /dev/random)
: "${REGISTRY:=ttl.sh}"
: "${REPOSITORY:=$REGISTRY/$DEFAULT_REPOSITORY}"
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'


# Install the sample pipeline.
echo -e "${C_GREEN}Creating a sample-pipeline: REPOSITORY=${REPOSITORY}${C_RESET_ALL}"
pushd "${GIT_ROOT}"
cue -t "repository=${REGISTRY}" apply ./examples/sample-pipeline | kubectl apply -f -
cue -t "repository=${REGISTRY}" create ./examples/sample-pipeline | kubectl create -f -
popd
tkn pipelinerun describe --last
