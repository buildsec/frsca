#!/bin/bash
set -euo pipefail

cd install
source 10-tekton-setup.sh
source 11-tekton-chains.sh

# The spire install script is super buggy - need to work on this
#source 20-spire-setup.sh

source 30-kyverno-setup.sh
source 31-opa-gatekeeper-setup.sh
cd ..