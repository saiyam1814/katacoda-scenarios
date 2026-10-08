#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-03-runtime-hardening
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
pod=$(one_ready_pod book-cks-readonly app=web)
kubectl -n book-cks-readonly exec "$pod" -- sh -c 'test "$(id -u)" = 1000 && wget -T 2 -qO- http://web:8080/hostname | grep . && echo writable >/tmp/test && test "$(cat /tmp/test)" = writable'
kubectl -n book-cks-readonly exec "$pod" -- cat /proc/mounts | python3 -c 'import sys; assert any(x.split()[1]=="/" and "ro" in x.split()[3].split(",") for x in sys.stdin)'
if kubectl -n book-cks-readonly exec "$pod" -- touch /blocked 2>/dev/null; then fail 'Root must be read-only'; fi
pass "Step 2: Keep an HTTP server working with a read-only root"
