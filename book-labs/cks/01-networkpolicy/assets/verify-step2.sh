#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-01-networkpolicy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
ip=$(kubectl -n book-cks-egress get service web -o jsonpath='{.spec.clusterIP}')
server=$(one_ready_pod book-cks-metadata app=web)
kubectl -n book-cks-metadata exec "$server" -- wget -T 2 -qO- "http://$ip" >/dev/null
if kubectl -n book-cks-egress exec client -- wget -T 2 -qO- "http://$ip" >/dev/null 2>&1; then fail 'Client egress remains allowed'; fi
kubectl -n book-cks-egress get networkpolicy deny-client-egress -o json | json_assert 'd["spec"]["podSelector"]=={} and "Egress" in d["spec"]["policyTypes"] and not d["spec"].get("egress")' 'Deny egress for all Pods in the namespace'
test -s "$WORK_DIR/deny-egress.yaml"
pass "Step 2: Deny egress from a namespace"
