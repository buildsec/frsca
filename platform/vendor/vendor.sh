#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

go install github.com/buildsec/vendorme@109f06dc20d01277f938a3a9fdd2f14f1c32ce2c

pushd "$GIT_ROOT/platform/vendor"
vendorme pull
popd
