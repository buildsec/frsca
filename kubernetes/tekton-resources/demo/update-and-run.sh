#!/usr/bin/env bash
set -u
set -e

remove_old_charts() {
    helm uninstall gatekeeper-template
    helm uninstall demo
}

install_new_charts() {
    helm upgrade -i gatekeeper-template gatekeeper-template
    helm upgrade -i demo image-verification --values image-verification/values.yaml
}


main(){
    #remove_old_charts "$@"
    install_new_charts "$@"
}

main "$@"
