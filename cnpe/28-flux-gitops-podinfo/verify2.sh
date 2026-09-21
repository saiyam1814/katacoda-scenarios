#!/bin/bash
set -euo pipefail
kubectl -n flux-system wait gitrepository/podinfo --for=condition=Ready --timeout=10s
kubectl -n flux-system wait helmrelease/podinfo-ui --for=condition=Ready --timeout=10s
kubectl -n apps-ui rollout status deploy/podinfo-ui --timeout=30s
# Values applied for real
[ "$(kubectl -n apps-ui get deploy podinfo-ui -o jsonpath='{.spec.replicas}' 2>/dev/null)" = "2" ] || exit 1
[ "$(kubectl -n apps-ui get svc podinfo-ui -o jsonpath='{.spec.type}' 2>/dev/null)" = "ClusterIP" ] || exit 1
COLOR=$(kubectl -n apps-ui get deploy podinfo-ui -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="PODINFO_UI_COLOR")].value}' 2>/dev/null)
[ "$COLOR" = "#336699" ] || exit 1

exit 0
