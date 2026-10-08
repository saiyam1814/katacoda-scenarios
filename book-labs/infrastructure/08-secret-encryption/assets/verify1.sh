#!/usr/bin/env bash
LAB_ID=infra-08-secret-encryption
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"
require_ready
python3 "$ASSET_DIR/check-encryption.py" "$STATE_DIR"
