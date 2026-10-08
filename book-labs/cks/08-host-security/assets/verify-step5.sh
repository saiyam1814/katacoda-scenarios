#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-08-host-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
grep -q ':9999' "$WORK_DIR/listener-before.txt"
grep -q 'python3' "$WORK_DIR/listener-before.txt"
grep -qx 'book-debug.service' "$WORK_DIR/listener-unit.txt"
if ss -H -lnt '( sport = :9999 )' | grep -q .; then fail 'Debug listener is still open'; fi
if systemctl is-active --quiet book-debug || systemctl is-enabled --quiet book-debug; then fail 'Stop and disable the unwanted service'; fi
systemctl is-active --quiet kubelet
systemctl is-active --quiet book-falco
kubectl get --raw=/readyz | grep -q ok
pass "Step 5: Remove an unwanted host listener"
