#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-12-csi-volumes
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-csi exec app -- df -Pk /data | awk 'NR==2 {print $2}' > "$WORK_DIR/before-kib.txt"
kubectl -n book-cka-csi patch pvc data --type=merge -p '{"spec":{"resources":{"requests":{"storage":"2Gi"}}}}'
kubectl -n book-cka-csi wait --for=jsonpath='{.status.capacity.storage}'=2Gi pvc/data --timeout=180s
kubectl -n book-cka-csi get pvc data -o yaml > "$WORK_DIR/expanded-pvc.yaml"
for attempt in $(seq 1 60); do
 size=$(kubectl -n book-cka-csi exec app -- df -Pk /data | awk 'NR==2 {print $2}')
 [[ "$size" -gt 1800000 ]] && break
 sleep 2
done
[[ "$size" -gt 1800000 ]] || fail 'The actual ext4 filesystem has not expanded'
kubectl -n book-cka-csi exec app -- cat /data/marker.txt
if kubectl -n book-cka-csi patch pvc data --type=merge --dry-run=server -p '{"spec":{"resources":{"requests":{"storage":"1Gi"}}}}'; then fail 'Unexpected shrink acceptance'; fi
