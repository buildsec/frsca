#!/bin/bash
set -exuo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

spire_apply() {
  if [ $# -lt 2 ] || [ "$1" != "-spiffeID" ]; then
    echo "spire_apply requires a spiffeID as the first arg" >&2
    exit 1
  fi

  show=$(kubectl exec -n spire spire-server-0 -c spire-server -- \
    /opt/spire/bin/spire-server entry show "$1" "$2")
  if [ "$show" != "Found 0 entries" ]; then
    # delete to recreate
    entryid=$(echo "$show" | grep "^Entry ID" | cut -f2 -d: | tr -d "[:space:]")
    kubectl exec -n spire spire-server-0 -c spire-server -- \
      /opt/spire/bin/spire-server entry delete -entryID "$entryid"
  fi
  kubectl exec -n spire spire-server-0 -c spire-server -- \
    /opt/spire/bin/spire-server entry create "$@"
}

kubectl create namespace spire --dry-run=client -o yaml | kubectl apply -f -

helm repo add sudo-bmitch https://sudo-bmitch.github.io/helm-charts
helm repo update
helm upgrade --install spire sudo-bmitch/spire \
  --values "${GIT_ROOT}/platform/components/spire/values.yaml" \
  --namespace spire --wait

kubectl rollout status -n spire statefulset/spire-server
kubectl rollout status -n spire daemonset/spire-agent

# Register Workloads.
spire_apply \
  -spiffeID spiffe://example.org/ns/spire/node/frsca \
  -selector k8s_psat:cluster:frsca \
  -selector k8s_psat:agent_ns:spire \
  -selector k8s_psat:agent_sa:spire-agent \
  -node
spire_apply \
  -spiffeID spiffe://example.org/ns/tekton-chains/sa/tekton-chains-controller \
  -parentID spiffe://example.org/ns/spire/node/frsca \
  -selector k8s:ns:tekton-chains \
  -selector k8s:sa:tekton-chains-controller
