#!/bin/bash
set -euo pipefail

# Define variables.
GIT_ROOT=$(git rev-parse --show-toplevel)
DEFAULT_REPOSITORY=$(xxd -l 16 -c 16 -p < /dev/random)
: "${REGISTRY:=ttl.sh}"
: "${REPOSITORY:=$REGISTRY/$DEFAULT_REPOSITORY}"
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Create prod namespace for deployment if it does not already exit
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -
# Create prod service account for deployment if it does not already exit
kubectl create sa pipeline-account -n prod --dry-run=client -o yaml | kubectl apply -f -

# Install the sample pipeline.
echo -e "${C_GREEN}Creating a sample-pipeline: REPOSITORY=${REPOSITORY}${C_RESET_ALL}"
kubectl apply -f "${GIT_ROOT}"/platform/vendor/tekton/catalog/main/task/git-clone/0.4/git-clone.yaml
kubectl apply -f "${GIT_ROOT}"/platform/vendor/tekton/catalog/main/task/kaniko/0.6/kaniko.yaml
pushd "${GIT_ROOT}"/examples/sample-pipeline
cue cmd -t "repository=${REPOSITORY}" apply | kubectl apply -f -
cue cmd -t "repository=${REPOSITORY}" create | kubectl create -f -
popd
tkn pipelinerun describe --last
