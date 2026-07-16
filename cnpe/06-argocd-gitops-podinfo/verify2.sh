#!/bin/bash
# App must be Synced and Healthy
SYNC=$(kubectl -n argocd get application podinfo-ui -o jsonpath='{.status.sync.status}' 2>/dev/null)
HEALTH=$(kubectl -n argocd get application podinfo-ui -o jsonpath='{.status.health.status}' 2>/dev/null)
[ "$SYNC" = "Synced" ] || exit 1
[ "$HEALTH" = "Healthy" ] || exit 1

# Values applied for real
[ "$(kubectl -n apps-ui get deploy podinfo-ui -o jsonpath='{.spec.replicas}' 2>/dev/null)" = "2" ] || exit 1
[ "$(kubectl -n apps-ui get svc podinfo-ui -o jsonpath='{.spec.type}' 2>/dev/null)" = "ClusterIP" ] || exit 1
COLOR=$(kubectl -n apps-ui get deploy podinfo-ui -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="PODINFO_UI_COLOR")].value}' 2>/dev/null)
[ "$COLOR" = "#336699" ] || exit 1

exit 0
