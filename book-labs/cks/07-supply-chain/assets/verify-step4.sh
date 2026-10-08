#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-07-supply-chain
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
expected=$(cat "$STATE_DIR/trusted-kubectl.sha256")
test "$(cat "$WORK_DIR/kubectl.sha256")" = "$expected"
printf '%s  %s\n' "$expected" "$WORK_DIR/bin/kubectl" | sha256sum -c -
test -s "$WORK_DIR/kubectl.tampered" && test -r "$WORK_DIR/kubectl.tampered" || fail 'Keep a readable, nonempty changed binary for the negative check'
actual=$(sha256sum "$WORK_DIR/kubectl.tampered" | awk '{print $1}')
[[ "$actual" != "$expected" ]] || fail 'The changed binary must contain different bytes'
if printf '%s  %s\n' "$expected" "$WORK_DIR/kubectl.tampered" | sha256sum -c - >"$STATE_DIR/tampered-check" 2>&1; then fail 'Modified binary must not match'; fi
grep -q ": FAILED$" "$STATE_DIR/tampered-check" || fail 'Expected a completed checksum mismatch, not a missing-file or read error'
"$WORK_DIR/bin/kubectl" version --client -o json | python3 -c 'import json,sys; assert json.load(sys.stdin)["clientVersion"]["gitVersion"]=="v1.35.0"'
pass "Step 4: Verify the official kubectl binary before using it"
