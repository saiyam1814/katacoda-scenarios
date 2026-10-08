#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-02-pod-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
bash "$(dirname "$0")/base-solution.sh"
kubectl -n book-cks-privileged patch deployment inspector --type=merge -p '{"spec":{"template":{"spec":{"securityContext":{"runAsUser":1000,"runAsGroup":1000,"runAsNonRoot":true},"containers":[{"name":"busybox","image":"busybox:1.37.0","command":["sh","-c","sleep 3600"],"securityContext":{"privileged":false,"allowPrivilegeEscalation":false,"readOnlyRootFilesystem":true,"capabilities":{"drop":["ALL"]}}}]}}}}'
ready_deploy book-cks-privileged inspector
kubectl -n book-cks-privileged get deployment inspector -o yaml > "$WORK_DIR/inspector.yaml"
