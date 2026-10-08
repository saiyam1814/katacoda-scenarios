#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-10-probes-configuration
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-config exec demo-pod -- sh -c 'test "$(cat /etc/config/colour)" = blue && test "$colour" = green' || fail 'The mounted file must update while the existing environment stays green'
pass "Step 2: Observe a mounted ConfigMap update"
