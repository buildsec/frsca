#!/bin/bash
set -xeuo pipefail

# Update below if you have a different config.json you want to use.
DOCKER_CONFIG_JSON=$HOME/.docker/config.json

# Helm setup from the getting install docs:
#   https://open-policy-agent.github.io/gatekeeper/website/docs/install/
#   Much of the OPA Gatekeeper work is based on the POC here: https://github.com/developer-guy/container-image-sign-and-verify-with-cosign-and-opa/tree/feature/verify-attestation

# Create secrets for gatekeeper/cosign wrapper api and kubernetes image pull
kubectl create namespace gatekeeper --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic regcred --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson=$DOCKER_CONFIG_JSON -n gatekeeper  --dry-run=client -o yaml | kubectl apply -f -

helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm upgrade -f enable-mutating.yaml --install gatekeeper gatekeeper/gatekeeper -n gatekeeper
