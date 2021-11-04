#!/bin/bash
set -euo pipefail

# Setup the OCI registry proxy.
export REGISTRY_PORT=$(minikube addons enable registry | grep -o -E "\d{5}")
docker run \
  --rm \
  -it \
  --network=host \
  alpine ash -c "apk add socat && socat TCP-LISTEN:${REGISTRY_PORT},reuseaddr,fork TCP:$(minikube ip):${REGISTRY_PORT}"
