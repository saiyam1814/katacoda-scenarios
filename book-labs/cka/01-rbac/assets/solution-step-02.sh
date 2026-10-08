#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-01-rbac
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
for sa in demo-sa demo2-sa; do kubectl -n book-cka-rbac create sa "$sa" --dry-run=client -o yaml | kubectl apply -f -; done
kubectl create clusterrole book-cka-creators --verb=create --resource=deployments.apps,daemonsets.apps --dry-run=client -o yaml | kubectl apply -f -
kubectl -n book-cka-rbac create rolebinding demo-create --clusterrole=book-cka-creators --serviceaccount=book-cka-rbac:demo-sa --dry-run=client -o yaml | kubectl apply -f -
kubectl -n book-cka-rbac create role deployments-only --verb=create --resource=deployments.apps --dry-run=client -o yaml | kubectl apply -f -
kubectl -n book-cka-rbac create rolebinding demo2-create --role=deployments-only --serviceaccount=book-cka-rbac:demo2-sa --dry-run=client -o yaml | kubectl apply -f -
