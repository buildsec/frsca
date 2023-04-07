#!/usr/bin/env bash
set -euo pipefail

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

GIT_ROOT=$(git rev-parse --show-toplevel)

cd "$GIT_ROOT/platform/vendor"

./vendor-helm-chart.sh "$@" -d ./spire/chart       -c spire          -v 0.1.3   -r https://sudo-bmitch.github.io/helm-charts
./vendor-helm-chart.sh "$@" -d ./vault/chart       -c vault          -v 0.20.0  -r https://helm.releases.hashicorp.com
./vendor-helm-chart.sh "$@" -d ./gatekeeper/chart  -c gatekeeper     -v 3.6.0   -r https://open-policy-agent.github.io/gatekeeper/charts
./vendor-helm-chart.sh "$@" -d ./elastic/chart     -c elasticsearch  -v 7.17.3  -r https://helm.elastic.co
./vendor-helm-chart.sh "$@" -d ./fluent/chart      -c fluent-bit     -v 0.20.1  -r https://fluent.github.io/helm-charts
./vendor-helm-chart.sh "$@" -d ./kibana/chart      -c kibana         -v 7.17.3  -r https://helm.elastic.co
./vendor-helm-chart.sh "$@" -d ./gitea/chart       -c gitea          -v 5.0.9   -r https://dl.gitea.io/charts/

echo -e "${C_GREEN}All helm charts vendored${C_RESET_ALL}"
