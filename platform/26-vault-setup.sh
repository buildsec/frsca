#!/bin/bash
set -exuo pipefail

# Define variables.
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_RESET_ALL='\033[0m'

cd "$(dirname $0)"
vault_name="$(kubectl get pods -l app.kubernetes.io/name=vault -n vault -o name | head -1)"
ROOT_TOKEN=""

vault_exec() {
  envcmd=""
  if [ -n "$ROOT_TOKEN" ]; then
    envcmd="env VAULT_TOKEN=$ROOT_TOKEN"
  fi
  kubectl exec -i -n vault $vault_name -- $envcmd vault "$@"
}

# wait for vault to start
vault_exec status 2>&1 | grep -q "^Initialized" || sleep 5

if [ ! -f components/vault/root-token ]; then
  INIT_OUT=$(vault_exec operator init --key-shares 1 --key-threshold 1)
  UNSEAL_KEY=$(echo "$INIT_OUT" | grep "Unseal Key" | sed 's/^.*: //')
  ROOT_TOKEN=$(echo "$INIT_OUT" | grep "Initial Root Token" | sed 's/^.*: //')
  echo "$UNSEAL_KEY" > components/vault/unseal-key
  echo "$ROOT_TOKEN" > components/vault/root-token
fi
UNSEAL_KEY="$(cat components/vault/unseal-key)"
ROOT_TOKEN="$(cat components/vault/root-token)"

if ! vault_exec status 2>&1 | grep "Sealed: false"; then
  vault_exec operator unseal "$UNSEAL_KEY"
fi

if ! vault_exec secrets list 2>&1 | grep "^transit/"; then
  vault_exec secrets enable transit
fi

if ! vault_exec auth list 2>&1 | grep "^jwt/"; then
  vault_exec auth enable jwt
fi

vault_exec read auth/jwt/config >/dev/null 2>&1 || \
vault_exec write auth/jwt/config \
  oidc_discovery_url=https://spire-oidc.spire.svc.cluster.local \
  default_role="spire"

vault_exec policy read spire-transit >/dev/null 2>&1 || \
vault_exec policy write spire-transit - <<EOF
path "transit/*" {
  capabilities = ["read"]
}
path "transit/sign/ssf" {
  capabilities = ["create", "read", "update"]
}
path "transit/sign/ssf/*" {
  capabilities = ["read", "update"]
}
path "transit/verify/ssf" {
  capabilities = ["create", "read", "update"]
}
path "transit/verify/ssf/*" {
  capabilities = ["read", "update"]
}
EOF

vault_exec read auth/jwt/role/spire-node-ssf >/dev/null 2>&1 || \
vault_exec write auth/jwt/role/spire-node-ssf \
  role_type=jwt \
  user_claim=sub \
  bound_audiences=TESTING \
  bound_subject=spiffe://example.org/ns/spire/node/ssf \
  token_ttl=15m \
  token_policies=spire-transit

vault_exec read auth/jwt/role/spire-agent >/dev/null 2>&1 || \
vault_exec write auth/jwt/role/spire-agent \
  role_type=jwt \
  user_claim=sub \
  bound_audiences=TESTING \
  bound_subject=spiffe://example.org/ns/spire/sa/spire-agent \
  token_ttl=15m \
  token_policies=spire-transit

vault_exec read auth/jwt/role/spire-default >/dev/null 2>&1 || \
vault_exec write auth/jwt/role/spire-default \
  role_type=jwt \
  user_claim=sub \
  bound_audiences=TESTING \
  bound_subject=spiffe://example.org/ns/default/sa/default \
  token_ttl=15m \
  token_policies=spire-transit

vault_exec read auth/jwt/role/spire-unknown-default >/dev/null 2>&1 || \
vault_exec write auth/jwt/role/spire-unknown-default \
  role_type=jwt \
  user_claim=sub \
  bound_audiences=TESTING \
  bound_subject=spiffe://example.org/ns/unknown/sa/default \
  token_ttl=15m \
  token_policies=spire-transit

vault_exec read auth/jwt/role/spire-chains-controller >/dev/null 2>&1 || \
vault_exec write auth/jwt/role/spire-chains-controller \
  role_type=jwt \
  user_claim=sub \
  bound_audiences=TESTING \
  bound_subject=spiffe://example.org/ns/tekton-chains/sa/tekton-chains-controller \
  token_ttl=15m \
  token_policies=spire-transit


vault_exec read transit/keys/ssf >/dev/null 2>&1 || \
vault_exec write transit/keys/ssf \
  type=ecdsa-p521

vault_exec read -format=json transit/keys/ssf \
  | jq -r .data.keys.\"1\".public_key >certs/ssf.pem

kubectl -n vault create configmap ssf-certs --from-file=ssf.pem="certs/ssf.pem" --dry-run=client -o=yaml | kubectl apply -f -
