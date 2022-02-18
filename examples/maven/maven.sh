#!/bin/bash
set -euo pipefail

# Define variables.
GIT_ROOT=$(git rev-parse --show-toplevel)
DEFAULT_REPOSITORY=$(xxd -l 16 -c 16 -p < /dev/random)
: "${REGISTRY:=ttl.sh}"
: "${REPOSITORY:=$REGISTRY/$DEFAULT_REPOSITORY}"
'\033[32m'
'\033[0m'

# Install shared tasks.
kubectl apply -f "${GIT_ROOT}"/platform/vendor/tekton/catalog/main/task/git-clone/0.4/git-clone.yaml
kubectl apply -f "${GIT_ROOT}"/platform/vendor/tekton/catalog/main/task/maven/0.2/maven.yaml

# Install the maven pipelinerun.
echo -e "${C_GREEN}Creating a maven pipelinerun: REPOSITORY=${REPOSITORY}${C_RESET_ALL}"
pushd "${GIT_ROOT}"
kubectl apply "repository=${REPOSITORY}" apply ./examples/mave/maven.yaml | kubectl apply -f -
kubectl apply "repository=${REPOSITORY}" create ./examples/maven/maven.yaml | kubectl create -f -
popd
tkn pipelinerun describe --last
