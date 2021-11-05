#!/bin/bash
set -exuo pipefail

cd "$(dirname $0)"
# GIT_ROOT=$(git rev-parse --show-toplevel)
# QUICKSTART_DIR=$GIT_ROOT/platform/vendor/spire/quickstart

# Define variables.
C_YELLOW='\033[33m'
C_RESET_ALL='\033[0m'

# Wait until pods are ready.
# $1: namespace, $2: app label
wait_for_pods () {
  echo -e "${C_YELLOW}Waiting: $2 pods in $1...${C_RESET_ALL}"
  kubectl wait --timeout=5m --for=condition=ready pods -l app="$2" -n "$1"
}

spire_apply() {
  if [ $# -lt 2 ] || [ "$1" != "-spiffeID" ]; then
    echo "spire_apply requires a spiffeID as the first arg" >&2
    exit 1
  fi

  show=$(kubectl exec -n spire spire-server-0 -c spire-server -- \
    /opt/spire/bin/spire-server entry show -socketPath /run/spire/sockets/server.sock $1 $2)
  if [ "$show" != "Found 0 entries" ]; then
    # delete to recreate
    entryid=$(echo "$show" | grep "^Entry ID" | cut -f2 -d:)
    kubectl exec -n spire spire-server-0 -c spire-server -- \
      /opt/spire/bin/spire-server entry delete -socketPath /run/spire/sockets/server.sock -entryID $entryid
  fi
  kubectl exec -n spire spire-server-0 -c spire-server -- \
    /opt/spire/bin/spire-server entry create -socketPath /run/spire/sockets/server.sock "$@"
}


kubectl create namespace spire --dry-run=client -o yaml | kubectl apply -f -

helm repo add sudo-bmitch https://sudo-bmitch.github.io/helm-charts
helm repo update
helm upgrade --install spire sudo-bmitch/spire --values components/spire/values.yaml --namespace spire --wait

# Register Workloads.
spire_apply \
  -spiffeID spiffe://example.org/ns/spire/node/ssf \
  -selector k8s_sat:cluster:ssf \
  -selector k8s_sat:agent_ns:spire \
  -selector k8s_sat:agent_sa:spire-agent \
  -node
spire_apply \
  -spiffeID spiffe://example.org/ns/spire/sa/spire-agent \
  -parentID spiffe://example.org/ns/spire/node/ssf \
  -selector k8s:ns:spire \
  -selector k8s:sa:spire-agent \
spire_apply \
  -spiffeID spiffe://example.org/ns/default/sa/default \
  -parentID spiffe://example.org/ns/spire/node/ssf \
  -selector k8s:ns:default \
  -selector k8s:sa:default

spire_apply \
  -spiffeID spiffe://example.org/ns/unknown/sa/default \
  -parentID spiffe://example.org/ns/spire/node/ssf \
  -selector k8s:sa:default
spire_apply \
  -spiffeID spiffe://example.org/ns/tekton-chains/sa/tekton-chains-controller \
  -parentID spiffe://example.org/ns/spire/node/ssf \
  -selector k8s:ns:tekton-chains \
  -selector k8s:sa:tekton-chains-controller

# # Configure a Workload Container to Access SPIRE.
# kubectl apply -f "${QUICKSTART_DIR}/client-deployment.yaml"

# Wait for the client
# sleep 1
# wait_for_pods default client
# sleep 5

# Verify that the container can access the socket.
kubectl exec -n spire -it \
  "$(kubectl get pods -n spire -o=jsonpath='{.items[0].metadata.name}' -l app=spire-client)" \
  -- /bin/sh -c "/opt/spire/bin/spire-agent api fetch -socketPath /run/spire/sockets/agent.sock"
