#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-09-ingress-mtls
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cks-ingress get ingress web -o json | json_assert 'd["spec"].get("ingressClassName")=="traefik" and d["spec"]["tls"][0]["secretName"]=="book-tls" and d["spec"]["tls"][0]["hosts"]==["book.test"]' 'Configure the TLS ingress'
node=$(cat "$WORK_DIR/node-ip.txt")
curl --noproxy '*' --max-time 3 --cacert "$WORK_DIR/book.crt" --resolve "book.test:30443:$node" -fsS https://book.test:30443/ | grep -qx book-tls-success
if curl --noproxy '*' --max-time 2 --cacert "$WORK_DIR/book.crt" --resolve "wrong.test:30443:$node" -fsS https://wrong.test:30443/ >"$STATE_DIR/wrong-tls" 2>&1; then fail 'Incorrect TLS hostname was accepted'; fi
grep -qiE 'certificate|subject|SSL' "$STATE_DIR/wrong-tls"
code=$(curl --noproxy '*' --max-time 3 --cacert "$WORK_DIR/book.crt" --resolve "book.test:30443:$node" -sS -H 'Host: wrong.test' -o /dev/null -w '%{http_code}' https://book.test:30443/)
test "$code" = 404
pass "Step 1: Serve an Ingress with a trusted TLS hostname"
