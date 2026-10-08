#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-12-csi-volumes
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-csi get pvc data -o json | json_assert 'd["spec"]["resources"]["requests"]["storage"]=="2Gi" and d["status"]["capacity"]["storage"]=="2Gi" and d["status"]["phase"]=="Bound" and not any(c.get("status")=="True" for c in d["status"].get("conditions",[]))' 'Wait for completed PVC expansion'
[[ $(kubectl -n book-cka-csi get pvc data -o jsonpath='{.metadata.uid}') == "$(cat "$WORK_DIR/pvc-uid.txt")" ]] || fail 'Expand the original claim without recreation'
kubectl create --dry-run=client -f "$WORK_DIR/expanded-pvc.yaml" -o json | json_assert 'd["metadata"]["name"]=="data" and d["spec"]["resources"]["requests"]["storage"]=="2Gi"' 'Save expanded PVC YAML'
size=$(kubectl -n book-cka-csi exec app -- df -Pk /data | awk 'NR==2 {print $2}')
before=$(cat "$WORK_DIR/before-kib.txt")
[[ "$before" -gt 0 && "$before" -lt 1100000 && "$size" -gt 1800000 && "$size" -gt "$before" ]] || fail 'Prove real filesystem growth, not just reported PVC capacity'
kubectl -n book-cka-csi exec app -- cat /data/marker.txt | grep -qx persistent-csi-data
if kubectl -n book-cka-csi patch pvc data --type=merge --dry-run=server -p '{"spec":{"resources":{"requests":{"storage":"1Gi"}}}}' > "$STATE_DIR/shrink-result" 2>&1; then fail 'Shrinking must be rejected'; fi
grep -qi 'forbidden' "$STATE_DIR/shrink-result" || fail 'The shrink check must fail for admission, not connectivity'
pass "Step 2: Expand the mounted ext4 filesystem without losing data"
