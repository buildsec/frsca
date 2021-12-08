#!/bin/bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

go install github.com/trmiller/vendorme@0b7091a0736be19ca2fd0a3245d997356822ba07

pushd "$GIT_ROOT/platform/vendor"
vendorme pull
popd
