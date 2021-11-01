#!/bin/bash
set -xeuo pipefail

# Spire setup from the getting started tutorial:
#   https://spiffe.io/docs/latest/try/getting-started-k8s/
#
# The resources can be found on GitHub at:
#   https://github.com/spiffe/spire-tutorials

# Define variables.
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_RESET_ALL='\033[0m'

# Wait until pods are ready.
# $1: namespace, $2: app label
wait_for_pods () {
  while [[ $(kubectl get pods --namespace $1 -l app=$2 -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
    echo -e "${C_YELLOW}Waiting for $2 pods in $1...${C_RESET_ALL}"
    sleep 1
  done
}

spire_apply() {
  if [ $# -lt 2 -o "$1" != "-spiffeID" ]; then
    echo "spire_apply requires a spiffeID as the first arg" >&2
    exit 1
  fi

  show=$(kubectl exec -n spire spire-server-0 -- \
    /opt/spire/bin/spire-server entry show $1 $2)
  if [ "$show" != "Found 0 entries" ]; then
    # delete to recreate
    entryid=$(echo "$show" | grep "^Entry ID" | cut -f2 -d:)
    kubectl exec -n spire spire-server-0 -- \
      /opt/spire/bin/spire-server entry delete -entryID $entryid
  fi
  kubectl exec -n spire spire-server-0 -- \
    /opt/spire/bin/spire-server entry create "$@"
}

# Define variables.
QUICKSTART_URL="https://raw.githubusercontent.com/spiffe/spire-tutorials/master/k8s/quickstart"

# Configure Kubernetes Namespace for SPIRE Components.
kubectl apply -f "${QUICKSTART_URL}/spire-namespace.yaml"

# Configure SPIRE Server.
# Create Server Bundle Configmap, Role & ClusterRoleBinding.
kubectl apply \
  -f "${QUICKSTART_URL}/server-account.yaml" \
  -f "${QUICKSTART_URL}/spire-bundle-configmap.yaml" \
  -f "${QUICKSTART_URL}/server-cluster-role.yaml"

# Create Server Configmap.
kubectl apply \
  -f "${QUICKSTART_URL}/server-configmap.yaml" \
  -f "${QUICKSTART_URL}/server-statefulset.yaml" \
  -f "${QUICKSTART_URL}/server-service.yaml"

# Configure and deploy the SPIRE Agent.
kubectl apply \
  -f "${QUICKSTART_URL}/agent-account.yaml" \
  -f "${QUICKSTART_URL}/agent-cluster-role.yaml"
kubectl apply \
  -f "${QUICKSTART_URL}/agent-configmap.yaml" \
  -f "${QUICKSTART_URL}/agent-daemonset.yaml"

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
kubectl apply -f "${QUICKSTART_URL}/client-deployment.yaml"

# Wait for the client
wait_for_pods default client
sleep 5

# Verify that the container can access the socket.
kubectl exec -it \
  $(kubectl get pods -o=jsonpath='{.items[0].metadata.name}' -l app=client) \
  -- /bin/sh -c "/opt/spire/bin/spire-agent api fetch -socketPath /run/spire/sockets/agent.sock"
