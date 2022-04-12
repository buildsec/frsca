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
kubectl apply -f "${GIT_ROOT}"/platform/vendor/tekton/catalog/main/task/maven/0.2/maven.yaml

# Install the maven pipelinerun.
echo -e "${C_GREEN}Creating a maven pipelinerun${C_RESET_ALL}"
pushd "${GIT_ROOT}"/examples/maven
cue cmd apply | kubectl apply -f -
cue cmd create | kubectl create -f -
popd
