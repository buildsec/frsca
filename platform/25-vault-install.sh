#!/bin/bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

kubectl create namespace vault --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install vault "${GIT_ROOT}/platform/vendor/vault/chart" \
  --values "${GIT_ROOT}/platform/components/vault/values.yaml" \
  --namespace vault --wait

# wait for vault to become initialized, it will become ready after being unsealed in the setup
kubectl wait --timeout=5m --for=condition=initialized \
  -n vault pods \
  -l statefulset.kubernetes.io/pod-name=vault-0
