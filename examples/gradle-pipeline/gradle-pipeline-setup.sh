#!/usr/bin/env bash
set -euo pipefail

# Define variables.
GIT_ROOT=$(git rev-parse --show-toplevel)
DEFAULT_REPOSITORY=$(xxd -l 16 -c 16 -p < /dev/random)
: "${REGISTRY:=ttl.sh}"
: "${REPOSITORY:=$REGISTRY/$DEFAULT_REPOSITORY}"
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Setup the gradle trigger.
echo -e "${C_GREEN}Creating a Gradle example trigger: REPOSITORY=${REPOSITORY}${C_RESET_ALL}"
pushd "${GIT_ROOT}"/examples/gradle-pipeline
cue cmd -t "repository=${REPOSITORY}" apply | kubectl apply -f -
popd

# wait for listener to be ready
kubectl wait --timeout=5m --for=condition=ready \
  eventlisteners.triggers.tekton.dev example-gradle-listener
