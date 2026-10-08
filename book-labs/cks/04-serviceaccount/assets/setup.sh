#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-04-serviceaccount
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin

bash "$(dirname "$0")/base-setup.sh"
reset_ns book-cks-secrets
kubectl get --raw=/.well-known/openid-configuration | python3 -c 'import json,sys; print(json.load(sys.stdin)["issuer"])' > "$STATE_DIR/token-audience"
kubectl -n book-cks-secrets create serviceaccount sam
kubectl -n book-cks-secrets create secret generic database --from-literal=username=admin --from-literal=password=book-lab-secret
kubectl -n book-cks-secrets create secret generic other --from-literal=value=unrelated
kubectl -n book-cks-secrets create role excess --verb='*' --resource='*'
kubectl -n book-cks-secrets create rolebinding excess --role=excess --serviceaccount=book-cks-secrets:sam

setup_done
