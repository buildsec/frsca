#!/bin/bash
set -euo pipefail

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

GIT_ROOT=$(git rev-parse --show-toplevel)

# Install Elastic
echo -e "${C_GREEN}Installing Elastic...${C_RESET_ALL}"
helm upgrade --install elasticsearch "${GIT_ROOT}/platform/vendor/elastic/chart" \
  --create-namespace --namespace logging \
  -f "${GIT_ROOT}/platform/components/elastic/values.yaml"

# Wait for Elastic
kubectl rollout status -n logging statefulset.apps/elasticsearch-master

# Install fluent-bit
echo -e "${C_GREEN}Installing fluent-bit...${C_RESET_ALL}"
helm upgrade --install fluent-bit "${GIT_ROOT}/platform/vendor/fluent/chart" \
  --create-namespace --namespace logging

# Install Kibana
echo -e "${C_GREEN}Installing kibana...${C_RESET_ALL}"
helm upgrade --install kibana "${GIT_ROOT}/platform/vendor/kibana/chart" \
  --create-namespace --namespace logging

# Wait for Kibana
kubectl rollout status -n logging deployment.apps/kibana-kibana

# To visualize Kibana port-forward 5601 and navigate to localhost:5601
# kubectl port-forward -n logging deployment/kibana-kibana 5601
