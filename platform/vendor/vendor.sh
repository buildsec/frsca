#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

go install github.com/trmiller/vendorme@57e3906787776d4c5412fb6330026fbeafc067cd

pushd "$GIT_ROOT/platform/vendor"
vendorme pull
popd
