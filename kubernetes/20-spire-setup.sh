#!/bin/bash
set -xeuo pipefail

# Spire setup from the getting started tutorial:
#   https://spiffe.io/docs/latest/try/getting-started-k8s/
#
# The resources can be found on GitHub at:
#   https://github.com/spiffe/spire-tutorials
#
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# ! THE SCRIPT IS NOT IDEMPOTENT !
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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

# Register Workloads.
# Note(rgreinhofer): This part is not idempotent!
#   Need to make a `create_or_update()` function.
kubectl exec -n spire spire-server-0 -- \
  /opt/spire/bin/spire-server entry create \
  -spiffeID spiffe://example.org/ns/spire/sa/spire-agent \
  -selector k8s_sat:cluster:demo-cluster \
  -selector k8s_sat:agent_ns:spire \
  -selector k8s_sat:agent_sa:spire-agent \
  -node
kubectl exec -n spire spire-server-0 -- \
  /opt/spire/bin/spire-server entry create \
  -spiffeID spiffe://example.org/ns/default/sa/default \
  -parentID spiffe://example.org/ns/spire/sa/spire-agent \
  -selector k8s:ns:default \
  -selector k8s:sa:default

# Configure a Workload Container to Access SPIRE.
kubectl apply -f "${QUICKSTART_URL}/client-deployment.yaml"

# Verify that the container can access the socket.
kubectl exec -it \
  $(kubectl get pods -o=jsonpath='{.items[0].metadata.name}' -l app=client) \
  -- /bin/sh -c "/opt/spire/bin/spire-agent api fetch -socketPath /run/spire/sockets/agent.sock"
