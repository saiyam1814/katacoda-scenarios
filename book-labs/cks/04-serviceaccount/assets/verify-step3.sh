#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-04-serviceaccount
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cks-secrets get pod consumer -o json | json_assert 'd["spec"].get("automountServiceAccountToken")==False and any(v.get("secret",{}).get("secretName")=="database" for v in d["spec"]["volumes"])' 'Use the database Secret and disable token automount'
kubectl -n book-cks-secrets exec consumer -- sh -c 'test "$DB_USER" = admin && test "$(cat /etc/db/password)" = book-lab-secret && test ! -e /var/run/secrets/kubernetes.io/serviceaccount/token'
if kubectl -n book-cks-secrets exec consumer -- sh -c 'echo changed > /etc/db/password' 2>/dev/null; then fail 'Secret mount must be read-only'; fi
pass "Step 3: Consume a Secret without mounting API credentials"
