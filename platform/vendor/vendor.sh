#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

go install github.com/buildsec/vendorme@eb12f64b0f166a7ccc7fad4cec4d1ee6c92d3e41

pushd "$GIT_ROOT/platform/vendor"
vendorme pull
popd
