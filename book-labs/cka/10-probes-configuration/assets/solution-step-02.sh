#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-10-probes-configuration
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-config patch configmap demo --type=merge -p '{"data":{"colour":"blue"}}'
wait_until 90 kubectl -n book-cka-config exec demo-pod -- sh -c 'test "$(cat /etc/config/colour)" = blue && test "$colour" = green'
