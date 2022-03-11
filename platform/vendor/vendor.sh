#!/bin/bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

go install github.com/trmiller/vendorme@8a3434544a548e6cebcd32d68136cb5fe5394dd1

pushd "$GIT_ROOT/platform/vendor"
vendorme pull
popd
