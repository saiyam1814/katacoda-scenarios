#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-07-pod-lifecycle
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-pods run saiyam --image=nginx:1.28.0
ready_pod book-cka-pods saiyam
kubectl -n book-cka-pods get pod saiyam -o jsonpath='{.spec.containers[0].image}{"\n"}' > "$WORK_DIR/image.txt"
