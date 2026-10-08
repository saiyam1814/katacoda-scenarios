#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-05-scheduling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-scheduling delete pod reporter --wait=true
kubectl -n book-cka-scheduling run reporter --image=busybox:1.37.0 --overrides='{"spec":{"nodeSelector":{"book-labs.example/disk":"ssd"}}}' --command -- sleep 3600
ready_pod book-cka-scheduling reporter
