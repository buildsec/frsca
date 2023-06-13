#!/usr/bin/env bash
set -euo pipefail

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Trigger the sample-pipeline pipelinerun.
echo -e "${C_GREEN}Triggering a sample-pipeline${C_RESET_ALL}"
kubectl -n gitea exec -i gitea-0 -c gitea -- su - git <<EOF
mkdir /tmp/example-sample-pipeline
cd /tmp/example-sample-pipeline
git clone https://frsca:demo1234@gitea-http:3000/frsca/example-sample-pipeline .
git commit -m 'Trigger Build' --allow-empty
git push
cd -
rm -rf /tmp/example-sample-pipeline
EOF
