#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-04-persistent-volume
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
# PVC sizes cannot be reduced in place. This claim is still unbound.
kubectl -n book-cka-storage delete pod writer --wait=true
kubectl -n book-cka-storage delete pvc data --wait=true
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: data, namespace: book-cka-storage}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: book-manual
  volumeName: book-cka-data
  resources:
    requests: {storage: 1Gi}
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
ready_pod book-cka-storage writer
kubectl -n book-cka-storage exec writer -- sh -c 'printf "book-data-survives\n" > /data/proof.txt'
