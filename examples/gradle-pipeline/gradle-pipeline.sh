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
kubectl apply -f "${GIT_ROOT}"/platform/vendor/tekton/catalog/main/task/jib-gradle/0.4/jib-gradle.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/trivy-scanner/0.1/trivy-scanner.yaml

# Install the buildpacks pipelinerun.
echo -e "${C_GREEN}Creating a Gradle pipelinerun: REPOSITORY=${REPOSITORY}${C_RESET_ALL}"
pushd "${GIT_ROOT}"
cue -t "repository=${REPOSITORY}" apply ./examples/gradle-pipeline | kubectl apply -f -
cue -t "repository=${REPOSITORY}" create ./examples/gradle-pipeline | kubectl create -f -
popd
tkn pipelinerun describe --last
