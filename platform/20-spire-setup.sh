#!/bin/bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)
QUICKSTART_DIR=$GIT_ROOT/platform/vendor/spire/quickstart

# Define variables.
#C_GREEN='\033[32m'
C_YELLOW='\033[33m'
#C_RED='\033[31m'
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

  show=$(kubectl exec -n spire spire-server-0 -- \
    /opt/spire/bin/spire-server entry show "$1" "$2")
  if [ "$show" != "Found 0 entries" ]; then
    # delete to recreate
    entryid=$(echo "$show" | grep "^Entry ID" | cut -f2 -d:)
    kubectl exec -n spire spire-server-0 -- \
      /opt/spire/bin/spire-server entry delete -entryID "$entryid"
  fi
  kubectl exec -n spire spire-server-0 -- \
    /opt/spire/bin/spire-server entry create "$@"
}

# Configure Kubernetes Namespace for SPIRE Components.
kubectl apply -f "${QUICKSTART_DIR}/spire-namespace.yaml"

# Configure SPIRE Server.
# Create Server Bundle Configmap, Role & ClusterRoleBinding.
kubectl apply \
  -f "${QUICKSTART_DIR}/server-account.yaml" \
  -f "${QUICKSTART_DIR}/spire-bundle-configmap.yaml" \
  -f "${QUICKSTART_DIR}/server-cluster-role.yaml"

# Create Server Configmap.
kubectl apply \
  -f "${QUICKSTART_DIR}/server-configmap.yaml" \
  -f "${QUICKSTART_DIR}/server-statefulset.yaml" \
  -f "${QUICKSTART_DIR}/server-service.yaml"

# Configure and deploy the SPIRE Agent.
kubectl apply \
  -f "${QUICKSTART_DIR}/agent-account.yaml" \
  -f "${QUICKSTART_DIR}/agent-cluster-role.yaml"
kubectl apply \
  -f "${QUICKSTART_DIR}/agent-configmap.yaml" \
  -f "${QUICKSTART_DIR}/agent-daemonset.yaml"

# Wait for spire-server and then spire-agent
wait_for_pods spire spire-server
wait_for_pods spire spire-agent

# Register Workloads.
spire_apply \
  -spiffeID spiffe://example.org/ns/spire/sa/spire-agent \
  -selector k8s_sat:cluster:demo-cluster \
  -selector k8s_sat:agent_ns:spire \
  -selector k8s_sat:agent_sa:spire-agent \
  -node
spire_apply \
  -spiffeID spiffe://example.org/ns/default/sa/default \
  -parentID spiffe://example.org/ns/spire/sa/spire-agent \
  -selector k8s:ns:default \
  -selector k8s:sa:default

# Configure a Workload Container to Access SPIRE.
kubectl apply -f "${QUICKSTART_DIR}/client-deployment.yaml"

# Wait for the client
sleep 1
wait_for_pods default client
sleep 5

# Verify that the container can access the socket.
kubectl exec -it \
  "$(kubectl get pods -o=jsonpath='{.items[0].metadata.name}' -l app=client)" \
  -- /bin/sh -c "/opt/spire/bin/spire-agent api fetch -socketPath /run/spire/sockets/agent.sock"
