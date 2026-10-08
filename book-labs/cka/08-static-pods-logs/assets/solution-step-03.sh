#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-08-static-pods-logs
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-hostpods logs logs-demo -c c2 > "$WORK_DIR/c2.txt"
kubectl -n book-cka-hostpods logs crash -c app --previous > "$WORK_DIR/previous.txt"
cat "$WORK_DIR/c2.txt" "$WORK_DIR/previous.txt"
