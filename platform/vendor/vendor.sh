#!/bin/bash
set -euo pipefail

go install github.com/trmiller/vendorme@91071b4ac30f03e42774f72ebf3fd80f57a710ea

vendorme pull
