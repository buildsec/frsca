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
kubectl apply -f "${GIT_ROOT}"/platform/vendor/buildpacks/tekton-integration/main/task/buildpacks/0.4/buildpacks.yaml
kubectl apply -f "${GIT_ROOT}"/platform/vendor/buildpacks/tekton-integration/main/task/buildpacks-phases/0.2/buildpacks-phases.yaml

# Install shared pipeline.
kubectl apply -f "${GIT_ROOT}"/platform/vendor/buildpacks/tekton-integration/main/pipeline/buildpacks/0.1/buildpacks.yaml

# Install the buildpacks pipelinerun.
echo -e "${C_GREEN}Creating a buildpacks pipelinerun: REPOSITORY=${REPOSITORY}${C_RESET_ALL}"
pushd "${GIT_ROOT}"/examples/buildpacks
cue cmd -t "repository=${REPOSITORY}" apply | kubectl apply -f -
cue cmd -t "repository=${REPOSITORY}" create | kubectl create -f -
popd
tkn pipelinerun describe --last
