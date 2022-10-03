#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

go install github.com/buildsec/vendorme@fbbf1eb56664a3ab1e8ec8898cd1cc6ca6740efd

pushd "$GIT_ROOT/platform/vendor"
vendorme pull
popd
