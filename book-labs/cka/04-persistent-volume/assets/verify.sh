#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-04-persistent-volume
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-storage get pvc data -o json | json_assert 'd["status"]["phase"] == "Bound" and d["spec"]["volumeName"] == "book-cka-data" and d["spec"]["resources"]["requests"]["storage"] == "1Gi"' 'Claim must bind to the static PV with a 1Gi request'
kubectl get pv book-cka-data -o json | json_assert 'd["spec"]["persistentVolumeReclaimPolicy"] == "Retain" and d["spec"]["capacity"]["storage"] == "1Gi"' 'PV capacity or reclaim policy changed'
ready_pod book-cka-storage writer
node=$(kubectl -n book-cka-storage get pod writer -o jsonpath='{.spec.nodeName}')
kubectl -n book-cka-storage delete pod verify-reader --ignore-not-found --wait=true >/dev/null
trap 'kubectl -n book-cka-storage delete pod verify-reader --ignore-not-found --wait=false >/dev/null 2>&1' EXIT
kubectl apply -f - <<YAML
apiVersion: v1
kind: Pod
metadata: {name: verify-reader, namespace: book-cka-storage}
spec:
  nodeName: $node
  restartPolicy: Never
  containers:
  - name: reader
    image: busybox:1.37.0
    command: [sh, -c, 'test "\$(cat /data/proof.txt)" = book-data-survives']
    volumeMounts: [{name: data, mountPath: /data, readOnly: true}]
  volumes:
  - name: data
    persistentVolumeClaim: {claimName: data}
YAML
for attempt in $(seq 1 60); do
  phase=$(kubectl -n book-cka-storage get pod verify-reader -o jsonpath='{.status.phase}')
  [[ "$phase" == Succeeded ]] && break
  [[ "$phase" == Failed ]] && fail 'Second Pod did not read the expected data from the volume'
  sleep 2
done
[[ "$phase" == Succeeded ]] || fail 'Timed out reading the PVC from a second Pod' 
pass "All checks passed for cka-04-persistent-volume"
