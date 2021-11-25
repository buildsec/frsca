#!/bin/bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)
QUICKSTART_DIR=${GIT_ROOT}/platform/vendor/spire/quickstart

# Spire setup from the getting started tutorial:
#   https://spiffe.io/docs/latest/try/getting-started-k8s/
#
# The resources can be found on GitHub at:
#   https://github.com/spiffe/spire-tutorials

# Define variables.
QUICKSTART_COMMIT=1a5b67f24011599dd9f4c17cd23403a60841726a
QUICKSTART_URL="https://raw.githubusercontent.com/spiffe/spire-tutorials/${QUICKSTART_COMMIT}/k8s/quickstart"

filesToDownload=(
	"agent-account.yaml"
	"agent-cluster-role.yaml"
	"agent-configmap.yaml"
	"agent-daemonset.yaml"
	"client-deployment.yaml"
	"server-account.yaml"
	"server-cluster-role.yaml"
	"server-configmap.yaml"
	"server-service.yaml"
	"server-statefulset.yaml"
	"spire-bundle-configmap.yaml"
	"spire-namespace.yaml"
)

# Download quick start files
for file in "${filesToDownload[@]}"; do
	curl "${QUICKSTART_URL}/${file}" >"${QUICKSTART_DIR}"/"${file}"
done
