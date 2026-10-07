#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-06-audit-policy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
SETUP_ACTIVE=1
rm -f "$STATE_DIR/ready" "$STATE_DIR/error"
trap 'code=$?; printf "Audit setup failed (exit %s).\n" "$code" > "$STATE_DIR/error"; exit "$code"' ERR
exec > >(tee "$STATE_DIR/setup.log") 2>&1
# This lab prepares only local files. It does not change API-server flags.
rm -f "$WORK_DIR/audit-policy.json"
cat > "$WORK_DIR/event-example.json" <<'JSON'
{"verb":"get","group":"","resource":"secrets"}
JSON
setup_done
