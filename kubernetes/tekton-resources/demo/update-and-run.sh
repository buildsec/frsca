#!/usr/bin/env bash
set -u
set -e

install_new_charts() {
    helm upgrade -i gatekeeper-template gatekeeper-template || true
    echo "Wait 5 seconds for gatekeeper-constraint-templates to become available"
    sleep 5
    helm upgrade -i demo image-verification --values image-verification/values.yaml || true
}

main(){
    install_new_charts "$@"
}

main "$@"
