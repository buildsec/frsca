#!/usr/bin/env bash
set -u
set -e

remove_old_charts() {
    helm uninstall gatekeeper-template || true 
    helm uninstall demo || true
}

main(){
    remove_old_charts "$@"
}

main "$@"
