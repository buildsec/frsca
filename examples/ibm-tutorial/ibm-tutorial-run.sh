#!/usr/bin/env bash
set -euo pipefail

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Trigger the ibm-tutorial pipelinerun.
echo -e "${C_GREEN}Triggering a ibm-tutorial pipelinerun${C_RESET_ALL}"
kubectl -n gitea exec -i gitea-0 -c gitea -- su - git <<EOF
mkdir /tmp/example-ibm-tutorial
cd /tmp/example-ibm-tutorial
git clone -b beta-update https://frsca:demo1234@gitea-http:3000/frsca/example-ibm-tutorial .
git commit -m 'Trigger Build' --allow-empty
git push origin beta-update
cd -
rm -rf /tmp/example-ibm-tutorial
EOF
