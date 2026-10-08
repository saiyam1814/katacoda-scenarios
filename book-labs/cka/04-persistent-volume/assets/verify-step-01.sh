#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-04-persistent-volume
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_pod_ready book-cka-storage reader
kubectl get pv book-cka-local-data -o json | json_assert 'd["status"]["phase"]=="Bound" and d["spec"].get("local",{}).get("path")=="/var/book-labs/cka-local/data" and "hostPath" not in d["spec"] and d["spec"]["persistentVolumeReclaimPolicy"]=="Retain" and d["spec"].get("nodeAffinity") and d["spec"]["claimRef"]["namespace"]=="book-cka-storage" and d["spec"]["claimRef"]["name"]=="data"' 'Require a bound local PV with node affinity and Retain'
kubectl get sc book-cka-local -o json | json_assert 'd["provisioner"]=="kubernetes.io/no-provisioner" and d["volumeBindingMode"]=="WaitForFirstConsumer"' 'Require delayed binding for local storage'
kubectl -n book-cka-storage exec reader -- cat /data/marker.txt | grep -qx local-volume-data || fail 'Read the existing marker through the PVC'
pass "Step 1: Bind a genuine static local volume"
