#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# Update below if you have a different config.json you want to use.
DOCKER_CONFIG_JSON=$HOME/.docker/config.json

# Helm setup from the getting install docs:
#   https://open-policy-agent.github.io/gatekeeper/website/docs/install/
#   Much of the OPA Gatekeeper work is based on the POC here: https://github.com/developer-guy/container-image-sign-and-verify-with-cosign-and-opa/tree/feature/verify-attestation

cleanup_cluster(){
    helm uninstall gatekeeper || true
    kubectl delete crd -l gatekeeper.sh/system=yes  || true
    kubectl delete ns gatekeeper || true
    kubectl delete PodSecurityPolicy gatekeeper-admin || true
    kubectl delete ClusterRole gatekeeper-manager-role || true
    kubectl delete ClusterRoleBinding gatekeeper-manager-rolebinding || true
    kubectl delete ValidatingWebhookConfiguration gatekeeper-validating-webhook-configuration|| true
    kubectl delete MutatingWebhookConfiguration gatekeeper-mutating-webhook-configuration || true
    kubectl delete secret generic regcred  || true
}


install_opa_gatekeeper(){
    helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
    helm upgrade -f ${SCRIPT_DIR}/../resources/opa-gatekeeper/enable-mutating.yaml --install gatekeeper gatekeeper/gatekeeper 
}


install_secrets(){
    # Create secrets for gatekeeper/cosign wrapper api and kubernetes image pull
    kubectl create namespace gatekeeper --dry-run=client -o yaml | kubectl apply -f -
    kubectl create secret generic regcred --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson=$DOCKER_CONFIG_JSON -n gatekeeper  --dry-run=client -o yaml | kubectl apply -f -
}


main() {
    cleanup_cluster "@"
    install_opa_gatekeeper "@"
    install_secrets "@"
}

main "$@"