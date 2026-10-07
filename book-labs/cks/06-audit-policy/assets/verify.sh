#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-06-audit-policy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
test -f "$STATE_DIR/ready" || fail "Run setup.sh first"
asset_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
python3 "$asset_dir/audit_verify.py" "$WORK_DIR/audit-policy.json"
pass "All checks passed for cks-06-audit-policy"
