#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-07-supply-chain
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
expected=$(cat "$STATE_DIR/trusted-kubectl.sha256")
test "$(cat "$WORK_DIR/kubectl.sha256")" = "$expected"
printf '%s  %s\n' "$expected" "$WORK_DIR/bin/kubectl" | sha256sum -c -
if printf '%s  %s\n' "$expected" "$WORK_DIR/kubectl.tampered" | sha256sum -c - >/dev/null 2>&1; then fail 'Modified binary must not match'; fi
"$WORK_DIR/bin/kubectl" version --client -o json | python3 -c 'import json,sys; assert json.load(sys.stdin)["clientVersion"]["gitVersion"]=="v1.35.0"'
pass "Step 4: Verify the official kubectl binary before using it"
