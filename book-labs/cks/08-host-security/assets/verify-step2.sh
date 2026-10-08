#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-08-host-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
grep -qx 'book-deny-tmp (enforce)' /sys/kernel/security/apparmor/profiles
kubectl -n book-cks-host get pod apparmor -o json | json_assert 'd["spec"]["containers"][0]["securityContext"]["appArmorProfile"]=={"type":"Localhost","localhostProfile":"book-deny-tmp"}' 'Use the modern Localhost AppArmor API'
kubectl -n book-cks-host exec apparmor -- sh -c 'cat /etc/hostname && echo works > /root/allowed && cat /proc/1/attr/current' | grep -q book-deny-tmp
if kubectl -n book-cks-host exec apparmor -- touch /tmp/blocked >"$STATE_DIR/apparmor-denial" 2>&1; then fail 'AppArmor did not deny the write'; fi
grep -qi 'Permission denied' "$STATE_DIR/apparmor-denial"
pass "Step 2: Enforce a real AppArmor profile"
