#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-03-runtime-hardening
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
reset_ns book-cks-runtime
kubectl -n book-cks-runtime create deployment worker --image=busybox:1.37.0 -- sh -c 'sleep 3600'
ready_deploy book-cks-runtime worker
setup_done
