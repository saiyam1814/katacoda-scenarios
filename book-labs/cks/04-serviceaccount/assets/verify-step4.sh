#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-04-serviceaccount
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl --kubeconfig="$WORK_DIR/reader.kubeconfig" config view --raw -o json | python3 -c 'import json,sys,base64,time; d=json.load(sys.stdin); assert len(d["users"])==1; u=d["users"][0]["user"]; assert set(u)=={"token"}; raw=u["token"].split(".")[1]; c=json.loads(base64.urlsafe_b64decode(raw+"="*(-len(raw)%4))); assert c["sub"]=="system:serviceaccount:book-cks-identity:reader"; assert c["kubernetes.io"]["namespace"]=="book-cks-identity"; assert c["kubernetes.io"]["serviceaccount"]["name"]=="reader"; assert 0<c["exp"]-c["iat"]<=660 and c["exp"]>time.time(); assert sys.argv[1] in c["aud"]' "$(cat "$STATE_DIR/token-audience")"
kubectl --request-timeout=3s --kubeconfig="$WORK_DIR/reader.kubeconfig" get configmap settings >/dev/null
for resource in 'configmap other' 'secrets'; do if kubectl --request-timeout=3s --kubeconfig="$WORK_DIR/reader.kubeconfig" get $resource >"$STATE_DIR/token-deny" 2>&1; then fail 'Short-lived reader token has excess access'; fi; grep -q Forbidden "$STATE_DIR/token-deny" || fail 'Denial must be authorization, not expired credentials'; done
pass "Step 4: Use a short-lived token with an isolated kubeconfig"
