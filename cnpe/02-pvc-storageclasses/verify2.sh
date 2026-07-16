#!/bin/bash
# PVCs exist with required spec
for pvc in pg-storage cdn-cache; do
  kubectl -n storage-lab get pvc "$pvc" >/dev/null 2>&1 || exit 1
  MODE=$(kubectl -n storage-lab get pvc "$pvc" -o jsonpath='{.spec.accessModes[0]}')
  SIZE=$(kubectl -n storage-lab get pvc "$pvc" -o jsonpath='{.spec.resources.requests.storage}')
  [ "$MODE" = "ReadWriteOnce" ] || exit 1
  [ "$SIZE" = "512Mi" ] || exit 1
done

# Right classes for each claim
[ "$(kubectl -n storage-lab get pvc pg-storage -o jsonpath='{.spec.storageClassName}')" = "fast-iops" ] || exit 1
[ "$(kubectl -n storage-lab get pvc cdn-cache -o jsonpath='{.spec.storageClassName}')" = "standard" ] || exit 1

# Both PVCs bound
[ "$(kubectl -n storage-lab get pvc pg-storage -o jsonpath='{.status.phase}')" = "Bound" ] || exit 1
[ "$(kubectl -n storage-lab get pvc cdn-cache -o jsonpath='{.status.phase}')" = "Bound" ] || exit 1

# Both apps running
kubectl -n storage-lab wait --for=condition=available deploy/pg deploy/cdn --timeout=10s >/dev/null 2>&1 || exit 1

exit 0
