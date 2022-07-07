#!/bin/bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

for ns in cert-manager registry spire tekton-chains tekton-pipelines vault; do
  kubectl create namespace "${ns}" --dry-run=client -o=yaml | kubectl apply -f -
done

kubectl apply -f "${GIT_ROOT}/platform/vendor/cert-manager/release/cert-manager.yaml"
kubectl rollout status -n cert-manager deployment/cert-manager-cainjector
kubectl rollout status -n cert-manager deployment/cert-manager
kubectl rollout status -n cert-manager deployment/cert-manager-webhook

kubectl -n cert-manager apply -f "${GIT_ROOT}/platform/components/cert-manager/ca.yaml"
kubectl -n registry apply -f "${GIT_ROOT}/platform/components/cert-manager/registry.yaml"
kubectl -n spire apply -f "${GIT_ROOT}/platform/components/cert-manager/spire.yaml"

# wait for cert secrets to be created
wait_cert() {
  echo "Waiting for certificate $1 - $2..."
  while [ "$(kubectl -n "$1" get secret "$2" -o jsonpath='{.data.tls\.crt}' 2>/dev/null)" == "" ]; do
    sleep 1
  done
}
wait_cert cert-manager rootca
wait_cert registry registry-certs
wait_cert spire oidc-cert

[ -d "${GIT_ROOT}/platform/certs" ] || mkdir -p "${GIT_ROOT}/platform/certs"

# create the CA cert chain
[ -d "${GIT_ROOT}/platform/certs/ca" ] || mkdir -p "${GIT_ROOT}/platform/certs/ca"
ca_cert="${GIT_ROOT}/platform/certs/ca/ca.pem"
ca_bundle="${GIT_ROOT}/platform/certs/ca/ca-bundle.pem"
ca_javacerts="${GIT_ROOT}/platform/certs/ca/java-cacerts.pem"
kubectl -n cert-manager get secret rootca -o jsonpath='{.data.ca\.crt}' | base64 -d >"${ca_cert}"

if [ -f "/etc/ssl/certs/ca-certificates.crt" ]; then
  cat "/etc/ssl/certs/ca-certificates.crt" "${ca_cert}" >"${ca_bundle}"
else
  docker run -it --rm alpine /bin/sh -c 'apk add ca-certificates >/dev/null 2>&1; cat /etc/ssl/certs/ca-certificates.crt' >"${ca_bundle}"
  cat "${ca_cert}" >>"${ca_bundle}"
fi

# convert CA bundle for Java
echo -e "${C_GREEN}Generating Java CA from gradle image...${C_RESET_ALL}"
docker run --rm -v "${ca_cert}:/tmp/cert.pem:ro" --entrypoint /bin/bash \
  gcr.io/cloud-builders/gradle \
    -c "openssl x509 -outform der -in /tmp/cert.pem -out /tmp/cert.der >&2 && \
        keytool -importcert -file /tmp/cert.der -storepass changeit -keystore /etc/ssl/certs/java/cacerts -trustcacerts -noprompt >&2 && \
        cat /etc/ssl/certs/java/cacerts" \
  >"${ca_javacerts}"

for ns in default registry tekton-chains tekton-pipelines; do
  kubectl -n "${ns}" create configmap ca-certs \
    --from-file=ca-certificates.crt="${ca_bundle}" \
    --dry-run=client -o=yaml | kubectl apply -f -
done

kubectl -n default create configmap java-certs \
  --from-file=cacerts="${ca_javacerts}" \
  --dry-run=client -o=yaml | kubectl apply -f -

kubectl -n vault create configmap ca-certs \
  --from-file=spire-ca.pem="${ca_cert}" \
  --dry-run=client -o=yaml | kubectl apply -f -
