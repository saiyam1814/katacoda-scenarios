#!/usr/bin/env bash
LAB_ID=infra-07-apiserver-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
python3 "$ASSET_DIR/check-audit.py"
