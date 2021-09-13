#!/bin/bash
set -xeuo pipefail

# Update below if you have a different config.json you want to use.
DOCKER_CONFIG_JSON=$HOME/.docker/config.json

# Kyverno setup from the getting started tutorial:
#   https://nirmata.com/2021/08/12/kubernetes-supply-chain-policy-management-with-cosign-and-kyverno/
#   Installation: https://kyverno.io/docs/installation/

# Create secrets for kaniko and kubernetes image pull
kubectl create namespace kyverno --dry-run=client -o yaml | kubectl apply -f -

# TODO: This should jsut be the normal secret if the kaniko task is updated to correctly use the docker config secret instead of requiring it to be hardcoded as config.json
kubectl create secret generic secret-dockerconfigjson --type=opaque --from-file=config.json=$DOCKER_CONFIG_JSON --dry-run=client -o yaml | kubectl apply -f -

# NOTE: Pull secret needs to exist in both kyverno namespace as well as the tekton task namespace (default in this case)
kubectl create secret generic regcred --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson=$DOCKER_CONFIG_JSON -n kyverno  --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic regcred --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson=$DOCKER_CONFIG_JSON --dry-run=client -o yaml | kubectl apply -f -

# Assumes helm already installed by previous scripts
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm upgrade --install kyverno-crds kyverno/kyverno-crds --namespace kyverno --create-namespace
helm upgrade --install kyverno kyverno/kyverno -n kyverno --set extraArgs="{--webhooktimeout=15,--imagePullSecrets=regcred}"
