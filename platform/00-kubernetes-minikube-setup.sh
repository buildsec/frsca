#!/usr/bin/env bash
set -euo pipefail

# TODO: Pin Brew versions for Mac
# TODO: Figure out a better mechanism for pinning versions in general
#       There are multiple ways to validate signatures, checksums, etc.

INSTALL_DIR=/usr/local/bin
CHECKSUM_FILE=download_checksum.txt

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
    minikube version || (
      brew untap -f "${USER}"/local-minikube || echo "${USER}/local-minikube already untapped"
      brew tap-new "${USER}"/local-minikube
      brew extract --version="${MINIKUBE_VERSION#v}" minikube "${USER}"/local-minikube
      brew install minikube@"${MINIKUBE_VERSION#v}"
    )
    helm version || brew install helm
    tkn version || brew install tektoncd-cli
    kubectl version --client || brew install kubectl
    cosign version || brew install sigstore/tap/cosign
    jq --version || brew install jq
    crane version || brew install crane
    ;;

  Linux)
    MINIKUBE_VERSION=$(cue cmd -t configName=minikube -t configItem=version config)
    MINIKUBE_FILE_NAME=$(cue cmd -t configName=minikube -t configItem=fileName config)
    MINIKUBE_URL=$(cue cmd -t configName=minikube -t configItem=asset config)
    [[ $(minikube version | awk '{print $3}' | xargs) == "$MINIKUBE_VERSION" ]] || (
      echo -e "${C_GREEN}minikube not found, installing...${C_RESET_ALL}"
      TMP=$(mktemp -d)
      pushd "$TMP"
      curl -LO "$MINIKUBE_URL"
      curl -LO "$MINIKUBE_URL.sha256"
      MINIKUBE_SHA256=$(<"$MINIKUBE_FILE_NAME.sha256")
      echo "$MINIKUBE_SHA256 $MINIKUBE_FILE_NAME" | sha256sum --check
      sudo install "${MINIKUBE_FILE_NAME}" "${INSTALL_DIR}"/minikube
      rm "$MINIKUBE_FILE_NAME"
      rm "$MINIKUBE_FILE_NAME.sha256"
      popd
      rmdir "$TMP"
    )

    HELM_DIR=$(cue cmd -t configName=helm -t configItem=dir config)
    HELM_VERSION=$(cue cmd -t configName=helm -t configItem=version config)
    HELM_FILE_NAME=$(cue cmd -t configName=helm -t configItem=fileName config)
    HELM_URL=$(cue cmd -t configName=helm -t configItem=asset config)
    [[ $(helm version | awk '{print $1 }' | sed -r 's/.*Version:\"(.*)\",/\1/') == "$HELM_VERSION" ]] || (
      echo -e "${C_GREEN}helm not found, installing...${C_RESET_ALL}"
      TMP=$(mktemp -d)
      pushd "$TMP"
      curl -LO "$HELM_URL"
      curl -LO "$HELM_URL.sha256"
      HELM_SHA256=$(<"$HELM_FILE_NAME.sha256")
      echo "$HELM_SHA256 $HELM_FILE_NAME" | sha256sum --check
      tar xvf "$HELM_FILE_NAME"
      sudo install "${HELM_DIR}/helm" $INSTALL_DIR/helm
      rm -rf "${HELM_DIR}"
      rm "$HELM_FILE_NAME"
      rm "$HELM_FILE_NAME.sha256"
      popd
      rmdir "$TMP"
    )

    TKN_FILE_NAME=$(cue cmd -t configName=tektonCli -t configItem=fileName config)
    TKN_URL=$(cue cmd -t configName=tektonCli -t configItem=releaseUrl config)
    TKN_CHECKSUMS=$(cue cmd -t configName=tektonCli -t configItem=checksums config)
    tkn version || (
      echo -e "${C_GREEN}tkn not found, installing...${C_RESET_ALL}"
      TMP=$(mktemp -d)
      pushd "$TMP"
      curl -LO "$TKN_URL/$TKN_FILE_NAME"
      curl -LO "$TKN_URL/$TKN_CHECKSUMS"
      grep "$TKN_FILE_NAME" "$TKN_CHECKSUMS" | sha256sum --check
      sudo tar xvzf "$TKN_FILE_NAME" -C "$INSTALL_DIR" tkn
      rm "$TKN_FILE_NAME"
      rm "$TKN_CHECKSUMS"
      popd
      rmdir "$TMP"
    )

    KUBECTL_URL=$(cue cmd -t configName=kubectl -t configItem=asset config)
    KUBECTL_VALIDATE_CHECKSUM_URL=$(cue cmd -t configName=kubectl -t configItem=checksumUrl config)
    kubectl version --client || (
      echo -e "${C_GREEN}kubectl not found, installing...${C_RESET_ALL}"
      TMP=$(mktemp -d)
      pushd "$TMP"
      curl -LO "$KUBECTL_URL"
      curl -LO "$KUBECTL_VALIDATE_CHECKSUM_URL"
      echo "$(<kubectl.sha256) kubectl" | sha256sum --check
      sudo install kubectl ${INSTALL_DIR}/kubectl
      rm kubectl
      rm kubectl.sha256
      popd
      rmdir "$TMP"
    )

    COSIGN_FILE_NAME=$(cue cmd -t configName=cosign -t configItem=fileName config)
    COSIGN_ASSET=$(cue cmd -t configName=cosign -t configItem=asset config)
    COSIGN_CHECKSUMS_FILE_NAME=$(cue cmd -t configName=cosign -t configItem=checksumsFileName config)
    COSIGN_CHECKSUMS_ASSET=$(cue cmd -t configName=cosign -t configItem=checksumsAsset config)
    cosign version || (
      echo -e "${C_GREEN}cosign not found, installing: ${COSIGN_ASSET}${C_RESET_ALL}"
      TMP=$(mktemp -d)
      pushd "$TMP"
      curl -sLO "${COSIGN_ASSET}"
      curl -sLO "${COSIGN_ASSET}.sig"
      curl -sLO "${COSIGN_CHECKSUMS_ASSET}"
      grep "$COSIGN_FILE_NAME" "$COSIGN_CHECKSUMS_FILE_NAME" |grep -v sbom > "$CHECKSUM_FILE"
      sha256sum -c "$CHECKSUM_FILE"
      sudo install "$COSIGN_FILE_NAME" "$INSTALL_DIR"/cosign
      rm "$COSIGN_FILE_NAME"
      rm "$COSIGN_CHECKSUMS_FILE_NAME"
      rm "$COSIGN_FILE_NAME".sig
      rm "$CHECKSUM_FILE"
      popd
      rmdir "$TMP"
    )

    jq --version || (
      echo -e "${C_GREEN}jq not found, installing...${C_RESET_ALL}" 
      
      if [ -x "$(command -v dnf)" ]; then
        sudo dnf install -y jq
      elif [ -x "$(command -v yum)" ]; then
        sudo yum install -y jq
      elif [ -x "$(command -v apt-get)" ]; then
        sudo apt-get install -y jq
      else 
        echo -e "${C_RED}jq cannot be automatically installed, please install it manually${C_RESET_ALL}"
        exit 1
      fi
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
    --extra-config=apiserver.api-audiences=api,spire-server \
    --extra-config=apiserver.authorization-mode=Node,RBAC \
    --memory max
fi

# Set up Minikube context.
echo -e "${C_GREEN}Configuring minikube context...${C_RESET_ALL}"
kubectl config use-context minikube

# Display a message to tell to update the environment variables.
minikube docker-env

# Manage default Ingress Controller.
minikube addons enable ingress
