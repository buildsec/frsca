#!/usr/bin/env bash
set -euo pipefail

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

GIT_ROOT=$(git rev-parse --show-toplevel)
: "${ZOLA_PORT:=8080}"

# Detect the platform.
PLATFORM=$(uname)

# Install packages if needed.
echo -e "${C_GREEN}Serving documentation on http://localhost:${ZOLA_PORT}/ (use cont-c to stop)...${C_RESET_ALL}"
case "${PLATFORM}" in

  Darwin)
    cd "${GIT_ROOT}/docs"
    zola serve --port "${ZOLA_PORT}" --base-url localhost
  ;;

  *)
    docker run \
      --rm -u "$(id -u):$(id -g)" \
      -v "${GIT_ROOT}:/app:z" --workdir /app/docs \
      -p "${ZOLA_PORT}:${ZOLA_PORT}" \
      ghcr.io/getzola/zola:v0.18.0 \
        serve --interface 0.0.0.0 --port "${ZOLA_PORT}" --base-url localhost
        ;;

esac
