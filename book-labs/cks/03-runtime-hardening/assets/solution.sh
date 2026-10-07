#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-03-runtime-hardening
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cks-runtime patch deployment worker --type=merge -p '{"spec":{"template":{"spec":{"securityContext":{"runAsNonRoot":true,"runAsUser":1000,"runAsGroup":1000,"fsGroup":1000,"seccompProfile":{"type":"RuntimeDefault"}},"containers":[{"name":"busybox","image":"busybox:1.37.0","command":["sh","-c","sleep 3600"],"securityContext":{"allowPrivilegeEscalation":false,"readOnlyRootFilesystem":true,"capabilities":{"drop":["ALL"]}},"volumeMounts":[{"name":"scratch","mountPath":"/tmp"}]}],"volumes":[{"name":"scratch","emptyDir":{}}]}}}}'
ready_deploy book-cks-runtime worker
