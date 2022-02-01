#!/bin/bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Update Bitnami repository.
helm repo add bitnami https://charts.bitnami.com/bitnami

# Install or upgrade kafka.
helm upgrade \
  kafka \
  bitnami/kafka \
  --install \
  --set livenessProbe.enabled=false \
  --set readinessProbe.enabled=false
