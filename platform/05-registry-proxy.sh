#!/bin/bash
set -euo pipefail

# Port forward the internal registry
: "${REGISTRY_PORT:=5000}"
: "${REGISTRY:=localhost:${REGISTRY_PORT}}"
C_GREEN='\033[32m'
C_CYAN='\033[36m'
C_RESET_ALL='\033[0m'

echo -e "${C_GREEN}Port forwarding the registry: REGISTRY=${REGISTRY}${C_RESET_ALL}"
echo -e "${C_CYAN}e.g.: curl http://${REGISTRY}/v2/_catalog${C_RESET_ALL}"
K8S_REGISTRY_PORT=$(kubectl get svc registry -n registry -o 'jsonpath={.spec.ports[?(@.name=="http")].port}')
kubectl port-forward --address 0.0.0.0 -n registry service/registry "${REGISTRY_PORT}":"$K8S_REGISTRY_PORT"
