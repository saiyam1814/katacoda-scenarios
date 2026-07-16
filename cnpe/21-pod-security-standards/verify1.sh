#!/bin/bash
for ns in fleet-1 fleet-2 fleet-3 fleet-4; do
  [ "$(kubectl get ns "$ns" -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/warn}')" = "baseline" ] || exit 1
  [ "$(kubectl get ns "$ns" -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/warn-version}')" = "latest" ] || exit 1
done
exit 0
