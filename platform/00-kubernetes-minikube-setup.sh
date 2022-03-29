#!/bin/bash
set -euo pipefail

# TODO: Pin Brew versions for Mac
# TODO: Figure out a better mechanism for pinning versions in general
#       There are multiple ways to validate signatures, checksums, etc.

# PINNED VERSIONS GO HERE
MINIKUBE_VERSION=v1.24.0
MINIKUBE_FILE_NAME=minikube-linux-amd64
MINIKUBE_URL=https://github.com/kubernetes/minikube/releases/download/$MINIKUBE_VERSION/$MINIKUBE_FILE_NAME
MINIKUBE_SHA256=3bc218476cf205acf11b078d45210a4882e136d24a3cbb7d8d645408e423b8fe

HELM_VERSION=v3.7.1
HELM_FILE_NAME=helm-v3.7.1-linux-amd64.tar.gz
HELM_URL=https://get.helm.sh/$HELM_FILE_NAME
HELM_SHA256="6cd6cad4b97e10c33c978ff3ac97bb42b68f79766f1d2284cfd62ec04cd177f4"

TKN_VERSION=v0.21.0
TKN_FILE_NAME=tkn_0.21.0_Linux_x86_64.tar.gz
TKN_URL=https://github.com/tektoncd/cli/releases/download/$TKN_VERSION/$TKN_FILE_NAME
TKN_SHA256=2158a202e4b04ff73e6427b565355c7bfc8cbe16dc7058a0414fb16e7b97008c

KUBECTL_VERSION=v1.22.3
KUBECTL_FILE_NAME=kubectl
KUBECTL_URL=https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl
KUBECTL_VALIDATE_CHECKSUM_URL=$KUBECTL_URL.sha256

COSIGN_ARCH=amd64
COSIGN_BIN=cosign
COSIGN_OS=$(uname | tr '[:upper:]' '[:lower:]')
COSIGN_VERSION=v1.2.1
COSIGN_RELEASE_URL="https://github.com/sigstore/cosign/releases/download/${COSIGN_VERSION}"
COSIGN_CHECKSUMS="cosign_checksums.txt"
COSIGN_ASSET="${COSIGN_BIN}-${COSIGN_OS}-${COSIGN_ARCH}"

CUE_VERSION=v0.4.2
CUE_FILE_NAME=cue_${CUE_VERSION}_linux_amd64.tar.gz
CUE_URL=https://github.com/cue-lang/cue/releases/download/${CUE_VERSION}
CUE_CHECKSUMS=checksums.txt

INSTALL_DIR=/usr/local/bin

# Define variables.
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_RESET_ALL='\033[0m'

# Detect the platform.
PLATFORM=$(uname)

# Install packages if needed.
echo -e "${C_GREEN}Installing packages if needed...${C_RESET_ALL}"
case "${PLATFORM}" in

  Darwin)
    minikube version || brew install minikube
    helm version || brew install helm
    tkn version || brew install tektoncd-cli
    kubectl version --client || brew install kubectl
    cosign version || brew install sigstore/tap/cosign
    cue version || brew install cuelang/tap/cue 
    jq --version || brew install jq
    ;;

  Linux)
    [[ $(minikube version | awk '{print $3}' | xargs) == "$MINIKUBE_VERSION" ]] || (
      echo -e "${C_GREEN}minikube not found, installing...${C_RESET_ALL}"
      TMP=$(mktemp -d)
      pushd "$TMP"
      curl -LO $MINIKUBE_URL
      ACTUAL_SHA256=$(sha256sum $MINIKUBE_FILE_NAME | awk '{print $1}')
      [[ $ACTUAL_SHA256 == "$MINIKUBE_SHA256" ]] || (
        echo "Expected SHA256 for $MINIKUBE_FILE_NAME: $MINIKUBE_SHA256"
        echo "Actual SHA256 for $MINIKUBE_FILE_NAME: $ACTUAL_SHA256"
        exit 1
      )
      sudo install $MINIKUBE_FILE_NAME $INSTALL_DIR/minikube
      rm $MINIKUBE_FILE_NAME
      popd
      rmdir "$TMP"
    )

    [[ $(helm version | awk '{print $1 }' | sed -r 's/.*Version:\"(.*)\",/\1/') == "$HELM_VERSION" ]] || (
      echo -e "${C_GREEN}helm not found, installing...${C_RESET_ALL}"
      TMP=$(mktemp -d)
      pushd "$TMP"
      curl -LO $HELM_URL
      ACTUAL_SHA256=$(sha256sum $HELM_FILE_NAME | awk '{print $1}')
      [[ $ACTUAL_SHA256 == "$HELM_SHA256" ]] || (
        echo "Expected SHA256 for $HELM_FILE_NAME: $HELM_SHA256"
        echo "Actual SHA256 for $HELM_FILE_NAME: $ACTUAL_SHA256"
        exit 1
      )
      tar xvf $HELM_FILE_NAME
      sudo install linux-amd64/helm $INSTALL_DIR/helm
      rm -rf linux-amd64
      rm $HELM_FILE_NAME
      popd
      rmdir "$TMP"
    )

    tkn version || (
      echo -e "${C_GREEN}tkn not found, installing...${C_RESET_ALL}"
      TMP=$(mktemp -d)
      pushd "$TMP"
      curl -LO $TKN_URL
      ACTUAL_SHA256=$(sha256sum $TKN_FILE_NAME | awk '{print $1}')
      [[ $ACTUAL_SHA256 == "$TKN_SHA256" ]] || (
        echo "Expected SHA256 for $TKN_FILE_NAME: $TKN_SHA256"
        echo "Actual SHA256 for $TKN_FILE_NAME: $ACTUAL_SHA256"
        exit 1
      )
      sudo tar xvzf $TKN_FILE_NAME -C /usr/local/bin tkn
      rm $TKN_FILE_NAME
      popd
      rmdir "$TMP"
    )

    kubectl version --client || (
      echo -e "${C_GREEN}kubectl not found, installing...${C_RESET_ALL}"
      TMP=$(mktemp -d)
      pushd "$TMP"
      curl -LO $KUBECTL_URL
      curl -LO $KUBECTL_VALIDATE_CHECKSUM_URL
      echo "$(<kubectl.sha256) kubectl" | sha256sum --check
      sudo install kubectl $INSTALL_DIR/kubectl
      rm $KUBECTL_FILE_NAME
      rm $KUBECTL_FILE_NAME.sha256
      popd
      rmdir "$TMP"
    )

    cosign version || (
      echo -e "${C_GREEN}cosign not found, installing...${C_RESET_ALL}"
      TMP=$(mktemp -d)
      pushd "$TMP"
      curl -sLO "${COSIGN_RELEASE_URL}/${COSIGN_ASSET}"
      curl -sLO "${COSIGN_RELEASE_URL}/${COSIGN_ASSET}.sig"
      curl -sLO "${COSIGN_RELEASE_URL}/${COSIGN_CHECKSUMS}"
      sha256sum --ignore-missing -c "${COSIGN_CHECKSUMS}"
      sudo install "$COSIGN_ASSET" $INSTALL_DIR/cosign
      rm "$COSIGN_ASSET"
      rm $COSIGN_CHECKSUMS
      rm "$COSIGN_ASSET".sig
      popd
      rmdir "$TMP"
    )

    cue version || (
      echo -e "${C_GREEN}cue not found, installing...${C_RESET_ALL}"
      TMP=$(mktemp -d)
      pushd "$TMP"
      curl -LO "${CUE_URL}/${CUE_FILE_NAME}"
      curl -LO "${CUE_URL}/${CUE_CHECKSUMS}"
      sha256sum --ignore-missing -c "${CUE_CHECKSUMS}"
      tar -xzf $CUE_FILE_NAME
      sudo install cue $INSTALL_DIR/cue
      rm "${CUE_CHECKSUMS}"
      rm $CUE_FILE_NAME
      rm -rf doc LICENSE README.md cue
      popd
      rmdir "$TMP"
    )
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

# Manage default Ingress Controller.
minikube addons enable ingress

# Setup Minikube's registry.
minikube addons enable registry

# Add/Update Helm chart repositories.
echo -e "${C_GREEN}Configuring helm...${C_RESET_ALL}"
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
