#!/bin/bash
set -euo pipefail

# Define variables.
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_RESET_ALL='\033[0m'

cd "$(dirname $0)"
kubectl create namespace vault --dry-run=client -o yaml | kubectl apply -f -

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm upgrade --install vault hashicorp/vault --values components/vault/values.yaml --namespace vault --wait

# TODO: wait for vault to become healthy
