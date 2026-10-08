#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-12-csi-volumes
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_pod_ready book-cka-csi app
[[ $(kubectl -n book-cka-csi get pvc data -o jsonpath='{.metadata.uid}') == "$(cat "$WORK_DIR/pvc-uid.txt")" ]] || fail 'Keep the original claim'
[[ $(kubectl -n book-cka-csi get pod app -o jsonpath='{.metadata.uid}') != "$(cat "$WORK_DIR/first-pod-uid.txt")" ]] || fail 'Recreate the Pod'
PV=$(kubectl -n book-cka-csi get pvc data -o jsonpath='{.spec.volumeName}')
kubectl get pv "$PV" -o json | json_assert 'd["status"]["phase"]=="Bound" and d["spec"].get("csi",{}).get("driver")=="local.csi.openebs.io" and d["spec"]["csi"]["volumeHandle"] and d["spec"]["persistentVolumeReclaimPolicy"]=="Delete"' 'Require a dynamically provisioned, genuine CSI volume'
kubectl -n book-cka-csi exec app -- cat /data/marker.txt | grep -qx persistent-csi-data || fail 'Data must persist after Pod recreation'
pass "Step 1: Provision a CSI volume and retain data across Pod recreation"
