#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-04-persistent-volume
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
NODE=$(cat "$WORK_DIR/node.txt")
cat > "$WORK_DIR/local-volume.yaml" <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: book-cka-local
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: book-cka-local-data
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: book-cka-local
  local:
    path: /var/book-labs/cka-local/data
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
  name: data
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
  name: reader
  namespace: book-cka-storage
spec:
  containers:
  - name: reader
    image: busybox:1.37.0
    command: [sh, -c, "cat /data/marker.txt; sleep 3600"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: data
YAML
kubectl apply -f "$WORK_DIR/local-volume.yaml"
ready_pod book-cka-storage reader
