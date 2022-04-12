#!/bin/bash
set -euo pipefail

# Define variables.
GIT_ROOT=$(git rev-parse --show-toplevel)
DEFAULT_REPOSITORY=$(xxd -l 16 -c 16 -p < /dev/random)
: "${REGISTRY:=ttl.sh}"
: "${REPOSITORY:=$REGISTRY/$DEFAULT_REPOSITORY}"
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Install shared tasks.
kubectl apply -f "${GIT_ROOT}"/platform/vendor/tekton/catalog/main/task/git-clone/0.4/git-clone.yaml

# Install the buildpacks pipelinerun.
echo -e "${C_GREEN}Creating a Ko pipelinerun: REPOSITORY=${REPOSITORY}${C_RESET_ALL}"
pushd "${GIT_ROOT}"
cue -t "repository=${REPOSITORY}" apply ./examples/cosign | kubectl apply -f -
cue -t "repository=${REPOSITORY}" create ./examples/cosign | kubectl create -f -
popd
tkn pipelinerun describe --last
