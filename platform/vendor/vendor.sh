#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

go install github.com/buildsec/vendorme@cee93cf3a994e0cf1f8b1e3d69fc4aaa144f2173

pushd "$GIT_ROOT/platform/vendor"
vendorme pull
popd
