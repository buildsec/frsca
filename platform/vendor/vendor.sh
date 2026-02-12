#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

go install github.com/buildsec/vendorme@5fa4b03bff273ae08e6fbfab9d07e6954ff88648

pushd "$GIT_ROOT/platform/vendor"
vendorme pull
popd
