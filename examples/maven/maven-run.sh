#!/usr/bin/env bash
set -euo pipefail

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Trigger the maven pipelinerun.
echo -e "${C_GREEN}Triggering a maven pipelinerun${C_RESET_ALL}"
kubectl -n gitea exec -i deploy/gitea -c gitea -- su - git <<EOF
mkdir /tmp/example-maven
cd /tmp/example-maven
git clone https://frsca:demo1234@gitea-http:3000/frsca/example-maven .
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git commit -m 'Trigger Build' --allow-empty
git push origin master
cd -
rm -rf /tmp/example-maven
EOF
