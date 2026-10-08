#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-04-serviceaccount
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cks-identity patch role reader --type=merge -p '{"rules":[{"apiGroups":[""],"resources":["configmaps"],"resourceNames":["settings"],"verbs":["get"]}]}'
kubectl -n book-cks-identity patch serviceaccount reader --type=merge -p '{"automountServiceAccountToken":false}'
kubectl -n book-cks-identity patch deployment worker --type=merge -p '{"spec":{"template":{"spec":{"automountServiceAccountToken":false}}}}'
ready_deploy book-cks-identity worker
