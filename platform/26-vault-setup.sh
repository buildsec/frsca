#!/bin/bash
set -exuo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

vault_name="$(kubectl get pods -l app.kubernetes.io/name=vault -n vault -o name | head -1)"
ROOT_TOKEN=""

vault_exec() {
  if [ -n "$ROOT_TOKEN" ]; then
    kubectl exec -i -n vault "$vault_name" -- env "VAULT_TOKEN=$ROOT_TOKEN" vault "$@"
  else
    kubectl exec -i -n vault "$vault_name" -- vault "$@"
  fi
}

# wait for vault to start, the status command may error
set +o pipefail
while ! vault_exec status 2>&1 | grep -q "^Initialized"; do
  sleep 5
done

if vault_exec status 2>&1 | grep -q '^Initialized.*false'; then
  INIT_OUT=$(vault_exec operator init --key-shares 1 --key-threshold 1)
  UNSEAL_KEY=$(echo "$INIT_OUT" | grep "Unseal Key" | sed 's/^.*: //')
  ROOT_TOKEN=$(echo "$INIT_OUT" | grep "Initial Root Token" | sed 's/^.*: //')
  echo "$UNSEAL_KEY" > "${GIT_ROOT}/platform/components/vault/unseal-key"
  echo "$ROOT_TOKEN" > "${GIT_ROOT}/platform/components/vault/root-token"
fi
UNSEAL_KEY="$(cat "${GIT_ROOT}/platform/components/vault/unseal-key")"
ROOT_TOKEN="$(cat "${GIT_ROOT}/platform/components/vault/root-token")"

if vault_exec status 2>&1 | grep -q '^Sealed.*true'; then
  vault_exec operator unseal "$UNSEAL_KEY"
fi
set -o pipefail

if ! vault_exec secrets list 2>&1 | grep "^transit/"; then
  vault_exec secrets enable transit
fi

if ! vault_exec auth list 2>&1 | grep "^jwt/"; then
  vault_exec auth enable jwt
fi

vault_exec read auth/jwt/config >/dev/null 2>&1 || \
vault_exec write auth/jwt/config \
  oidc_discovery_url=https://spire-oidc.spire.svc.cluster.local \
  default_role="spire-chains-controller"

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
  | jq -r .data.keys.\"1\".public_key >"${GIT_ROOT}/platform/certs/ssf.pem"

kubectl -n vault create configmap ssf-certs --from-file=ssf.pem="${GIT_ROOT}/platform/certs/ssf.pem" --dry-run=client -o=yaml | kubectl apply -f -

COSIGN_KEY=$(kubectl get secret signing-secrets -n tekton-chains -o jsonpath='{.data.cosign\.key}' 2> /dev/null || true)
if [ -n "${COSIGN_KEY}" ]; then
  # remove signing-secrets if created by cosign
  kubectl -n tekton-chains delete secret signing-secrets
fi
( kubectl -n tekton-chains create secret generic signing-secrets \
    --from-file=cosign.pub="${GIT_ROOT}/platform/certs/ssf.pem" \
    --dry-run=client -o yaml
  echo "immutable: true"
) | kubectl apply -f -
