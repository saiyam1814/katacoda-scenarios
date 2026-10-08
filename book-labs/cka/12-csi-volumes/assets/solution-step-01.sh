#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-12-csi-volumes
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl apply -f - <<'YAML'
{
  "apiVersion": "storage.k8s.io/v1",
  "kind": "StorageClass",
  "metadata": {
    "name": "book-cka-expandable"
  },
  "provisioner": "local.csi.openebs.io",
  "allowVolumeExpansion": true,
  "volumeBindingMode": "WaitForFirstConsumer",
  "reclaimPolicy": "Delete",
  "parameters": {
    "storage": "lvm",
    "volgroup": "book_cka_csi",
    "fsType": "ext4"
  }
}
---
{
  "apiVersion": "v1",
  "kind": "PersistentVolumeClaim",
  "metadata": {
    "name": "data",
    "namespace": "book-cka-csi"
  },
  "spec": {
    "accessModes": [
      "ReadWriteOnce"
    ],
    "storageClassName": "book-cka-expandable",
    "resources": {
      "requests": {
        "storage": "1Gi"
      }
    }
  }
}
---
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "app",
    "namespace": "book-cka-csi"
  },
  "spec": {
    "containers": [
      {
        "name": "app",
        "image": "busybox:1.37.0",
        "command": [
          "sleep",
          "3600"
        ],
        "volumeMounts": [
          {
            "name": "data",
            "mountPath": "/data"
          }
        ]
      }
    ],
    "volumes": [
      {
        "name": "data",
        "persistentVolumeClaim": {
          "claimName": "data"
        }
      }
    ]
  }
}
YAML

ready_pod book-cka-csi app
kubectl -n book-cka-csi exec app -- sh -c 'echo persistent-csi-data > /data/marker.txt'
kubectl -n book-cka-csi get pvc data -o jsonpath='{.metadata.uid}' > "$WORK_DIR/pvc-uid.txt"
kubectl -n book-cka-csi get pod app -o jsonpath='{.metadata.uid}' > "$WORK_DIR/first-pod-uid.txt"
kubectl -n book-cka-csi delete pod app --wait=true
kubectl apply -f - <<'YAML'
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "app",
    "namespace": "book-cka-csi"
  },
  "spec": {
    "containers": [
      {
        "name": "app",
        "image": "busybox:1.37.0",
        "command": [
          "sleep",
          "3600"
        ],
        "volumeMounts": [
          {
            "name": "data",
            "mountPath": "/data"
          }
        ]
      }
    ],
    "volumes": [
      {
        "name": "data",
        "persistentVolumeClaim": {
          "claimName": "data"
        }
      }
    ]
  }
}
YAML

ready_pod book-cka-csi app
kubectl -n book-cka-csi exec app -- cat /data/marker.txt
