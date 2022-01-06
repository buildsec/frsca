#!/bin/bash
set -euo pipefail

# Define variables.
GIT_ROOT=$(git rev-parse --show-toplevel)
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Create the IBM tutorial pipelinerun.
echo -e "${C_GREEN}Creating a IBM tutorial pipelinerun...${C_RESET_ALL}"
kubectl apply -f "${GIT_ROOT}"/platform/vendor/tekton/catalog/main/task/git-clone/0.4/git-clone.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/chains/main/examples/kaniko/kaniko.yaml
pushd "${GIT_ROOT}"
cue apply ./examples/ibm-tutorial | kubectl apply -f -
cue create ./examples/ibm-tutorial | kubectl create -f -
popd
tkn pipelinerun describe --last
