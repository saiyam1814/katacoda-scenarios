#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-04-persistent-volume
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
reset_ns book-cka-storage
kubectl delete pv book-cka-data --ignore-not-found --wait=true --timeout=60s
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: PersistentVolume
metadata: {name: book-cka-data}
spec:
  capacity: {storage: 1Gi}
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: book-manual
  hostPath: {path: /var/book-labs/cka-storage, type: DirectoryOrCreate}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: data, namespace: book-cka-storage}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: book-manual
  volumeName: book-cka-data
  resources:
    requests: {storage: 2Gi}
---
apiVersion: v1
kind: Pod
metadata: {name: writer, namespace: book-cka-storage}
spec:
  containers:
  - name: writer
    image: busybox:1.37.0
    command: [sh, -c, 'sleep 3600']
    volumeMounts: [{name: data, mountPath: /data}]
  volumes:
  - name: data
    persistentVolumeClaim: {claimName: data}
YAML
setup_done
