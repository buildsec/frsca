#!/bin/bash
set -euo pipefail

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Detect the platform.
PLATFORM=$(uname)

# Install packages if needed.
echo -e "${C_GREEN}Installing packages if needed...${C_RESET_ALL}"
case "${PLATFORM}" in
  Darwin)
  node --version || brew install node
  ;;
esac