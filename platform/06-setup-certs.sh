#!/bin/bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Following mainly for MacOS, as supplies LibreSSL by default
[ "$(openssl version|awk '{print$1}')" = "LibreSSL" ] && { echo "LibreSSL is not supported, please install Openssl"; exit 1;}

[ -d "${GIT_ROOT}/platform/certs" ] || mkdir -p "${GIT_ROOT}/platform/certs"

## TODO: if openssl is not installed, consider running command with a temporary container

# create the CA key/cert
[ -d "${GIT_ROOT}/platform/certs/ca" ] || mkdir -p "${GIT_ROOT}/platform/certs/ca"
ca_key="${GIT_ROOT}/platform/certs/ca/ca-key.pem"
ca_cert="${GIT_ROOT}/platform/certs/ca/ca.pem"
[ -f "$ca_key" ] || openssl genrsa -out "$ca_key" 4096
openssl req -new -x509 \
  -key "$ca_key" \
  -days 3650 \
  -subj "/CN='Demo CA'" \
  -addext "basicConstraints=CA:true" \
  -sha256 -out "$ca_cert"

node_cert() {
  node="$1"
  dir="${GIT_ROOT}/platform/certs/${node}"
  [ -d "${dir}" ] || mkdir -p "${dir}"
  [ -f "${dir}/key.pem" ] || openssl genrsa -out "${dir}/key.pem" 2048
  openssl req \
    -new -subj "/CN=${node}" \
    -key "${dir}/key.pem" -out "${dir}/cert.csr"
  # configure cnf with various options
  echo "basicConstraints = CA:FALSE" >"${dir}/cert.cnf"
  echo "keyUsage = digitalSignature,keyEncipherment" >>"${dir}/cert.cnf"
  echo "extendedKeyUsage = serverAuth,clientAuth" >>"${dir}/cert.cnf"
  if [ -n "$2" ]; then
    echo "subjectAltName = ${2}" >>"${dir}/cert.cnf"
  fi
  openssl x509 -req -sha256 \
    -days 365 \
    -CA "$ca_cert" -CAkey "$ca_key" -CAcreateserial \
    -extfile "${dir}/cert.cnf" \
    -in "${dir}/cert.csr" -out "${dir}/cert.pem"
    # -extfile "./openssl.cfg" \
    # -extensions v3_req \
  cat "${dir}/cert.pem" "${ca_cert}" >"${dir}/cert-chain.pem"
}

node_cert spire-oidc DNS:spire-oidc.spire.svc.cluster.local,DNS:oidc.example.org,DNS:oidc

kubectl create namespace spire --dry-run=client -o=yaml | kubectl apply -f -
kubectl create namespace vault --dry-run=client -o=yaml | kubectl apply -f -
kubectl -n spire create secret tls oidc-cert \
  --cert="${GIT_ROOT}/platform/certs/spire-oidc/cert-chain.pem" \
  --key="${GIT_ROOT}/platform/certs/spire-oidc/key.pem" \
  --dry-run=client -o=yaml | kubectl apply -f -
kubectl -n vault create configmap ca-certs \
  --from-file=spire-ca.pem="${ca_cert}" \
  --dry-run=client -o=yaml | kubectl apply -f -
