#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-01-networkpolicy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
ip=$(kubectl -n book-cks-egress get service web -o jsonpath='{.spec.clusterIP}')
server=$(one_ready_pod book-cks-egress app=web)
kubectl -n book-cks-egress exec "$server" -- wget -T 2 -qO- "http://$ip" >/dev/null
if kubectl -n book-cks-egress exec client -- wget -T 2 -qO- "http://$ip" >/dev/null 2>&1; then fail 'Client egress remains allowed'; fi
test -s "$WORK_DIR/deny-egress.yaml"
pass "Step 2: Deny egress from one workload"
