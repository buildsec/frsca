#!/usr/bin/env bash
set -euo pipefail

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

GIT_ROOT=$(git rev-parse --show-toplevel)
: "${ZOLA_PORT:=8080}"

echo -e "${C_GREEN}Serving documentation on http://localhost:${ZOLA_PORT}/ (use cont-c to stop)...${C_RESET_ALL}"
docker run \
  -u "$(id -u):$(id -g)" \
  -v "${GIT_ROOT}:/app" --workdir /app/docs \
  -p "${ZOLA_PORT}:${ZOLA_PORT}" \
  ghcr.io/getzola/zola:v0.15.1 \
    serve --interface 0.0.0.0 --port "${ZOLA_PORT}" --base-url localhost
