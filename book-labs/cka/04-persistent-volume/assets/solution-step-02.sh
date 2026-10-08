#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-04-persistent-volume
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
NODE=$(cat "$WORK_DIR/node.txt")
cat > "$WORK_DIR/retained.yaml" <<YAML
apiVersion: v1
kind: PersistentVolume
metadata:
  name: book-cka-local-retained
spec:
  capacity:
    storage: 1Gi
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: book-cka-local
  local:
    path: /var/book-labs/cka-local/retained
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values: ["$NODE"]
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: retained
  namespace: book-cka-storage
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: book-cka-local
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: writer
  namespace: book-cka-storage
spec:
  containers:
  - name: writer
    image: busybox:1.37.0
    command: [sh, -c, "echo retained-after-claim-deletion > /data/retained.txt; sleep 3600"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: retained
YAML
kubectl apply -f "$WORK_DIR/retained.yaml"
ready_pod book-cka-storage writer
kubectl -n book-cka-storage get pvc retained -o jsonpath='{.metadata.uid}' > "$WORK_DIR/deleted-claim-uid.txt"
kubectl -n book-cka-storage delete pod writer --wait=true
kubectl -n book-cka-storage delete pvc retained --wait=true
kubectl wait --for=jsonpath='{.status.phase}'=Released pv/book-cka-local-retained --timeout=60s
