#!/bin/bash
set -euo pipefail

# Define variables.
GIT_ROOT=$(git rev-parse --show-toplevel)
DEFAULT_REPOSITORY=$(xxd -l 16 -c 16 -p < /dev/random)
: "${REGISTRY:=ttl.sh}"
: "${REPOSITORY:=$REGISTRY/$DEFAULT_REPOSITORY}"
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_RESET_ALL='\033[0m'

# Install shared tasks.
kubectl apply -f "${GIT_ROOT}"/platform/vendor/tekton/catalog/main/task/git-clone/0.4/git-clone.yaml
kubectl apply -f https://raw.githubusercontent.com/buildpacks/tekton-integration/main/task/buildpacks/0.4/buildpacks.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/buildpacks-phases/0.2/buildpacks-phases.yaml

# Install shared pipeline.
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/pipeline/buildpacks/0.1/buildpacks.yaml

# Install the buildpacks pipelinerun.
kubectl apply -f ${GIT_ROOT}/examples/buildpacks/pipeline-pvc.yaml

echo -e "${C_GREEN}Creating a buildpacks pipelinerun: REPOSITORY=${REPOSITORY}${C_RESET_ALL}"
cue export ${GIT_ROOT}/examples/buildpacks/pipelinerun-buildpacks.cue -t repository="${REPOSITORY}" | kubectl create -f -
tkn pipelinerun describe --last
