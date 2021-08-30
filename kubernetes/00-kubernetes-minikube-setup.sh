#!/bin/bash
set -euo pipefail

# Define variables.
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_RESET_ALL='\033[0m'

# Detect the platform.
PLATFORM=$(uname)

# Install packages if needed.
echo -e "${C_GREEN}Installing paackages if needed...${C_RESET_ALL}"
case "${PLATFORM}" in

  Darwin)
    minikube version || brew install minikube
    helm version || brew install helm
    brew tap tektoncd/tools
    tkn version || brew install tektoncd/tools/tektoncd-cli
    ;;

  *)
    echo -e "${C_RED}The ${PLATFORM} platform is unimplemented or unsupported.${C_RESET_ALL}"
    exit 1
    ;;

esac

# Start the service.
# shellcheck disable=SC1083
MINIKUBE_STATUS=$(minikube status --format  {{.Host}} || true)
if [ "${MINIKUBE_STATUS}" == "Running" ]; then
  echo -e "${C_YELLOW}Minikube is already running.${C_RESET_ALL}"
else
  echo -e "${C_GREEN}Starting Minikube...${C_RESET_ALL}"
  minikube start \
    --driver=docker \
    --extra-config=apiserver.service-account-signing-key-file=/var/lib/minikube/certs/sa.key \
    --extra-config=apiserver.service-account-key-file=/var/lib/minikube/certs/sa.pub \
    --extra-config=apiserver.service-account-issuer=api \
    --extra-config=apiserver.service-account-api-audiences=api,spire-server \
    --extra-config=apiserver.authorization-mode=Node,RBAC
fi

# Set up Minikube context.
echo -e "${C_GREEN}Configuring minikube context...${C_RESET_ALL}"
kubectl config use-context minikube

# Display a message to tell to update the environment variables.
minikube docker-env

# Note(rgreinhofer): this is currently not supported for M1 chips.
#   ❌  Exiting due to MK_USAGE: Due to networking limitations of driver docker
#       on darwin, ingress addon is not supported.
#   Alternatively to use this addon you can use a vm-based driver:
#
# 	  'minikube start --vm=true'
#
#   To track the update on this work in progress feature please check:
#   https://github.com/kubernetes/minikube/issues/7332
# Manage default Ingress Controller.
# minikube addons enable ingress

# Setup Minikube's registry.
minikube addons enable registry

# Add/Update Helm chart repositories.
echo -e "${C_GREEN}Configuring helm...${C_RESET_ALL}"
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
