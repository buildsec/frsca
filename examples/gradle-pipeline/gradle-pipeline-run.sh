#!/usr/bin/env bash
set -euo pipefail

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Trigger the gradle pipelinerun.
echo -e "${C_GREEN}Triggering a gradle pipelinerun${C_RESET_ALL}"
kubectl -n gitea exec -i gitea-0 -c gitea -- su - git <<EOF
mkdir /tmp/example-gradle
cd /tmp/example-gradle
git clone https://frsca:demo1234@gitea-http:3000/frsca/example-gradle .
git commit -m 'Trigger Build' --allow-empty
git push origin master
cd -
rm -rf /tmp/example-gradle
EOF
