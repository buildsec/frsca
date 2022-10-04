#!/usr/bin/env bash
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

# Setup the sample-pipeline trigger.
echo -e "${C_GREEN}Creating a sample-pipeline example trigger: REPOSITORY=${REPOSITORY}${C_RESET_ALL}"
pushd "${GIT_ROOT}"/examples/sample-pipeline
cue cmd -t "repository=${REPOSITORY}" apply | kubectl apply -f -
popd

# wait for listener to be ready
kubectl wait --timeout=5m --for=condition=ready \
  eventlisteners.triggers.tekton.dev example-sample-pipeline-listener
