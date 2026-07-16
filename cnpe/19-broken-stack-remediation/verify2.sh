#!/bin/bash
# Both deployments available
kubectl -n metrics-portal wait --for=condition=available deploy/metrics-db --timeout=5s >/dev/null 2>&1 || exit 1
kubectl -n metrics-portal wait --for=condition=available deploy/metrics-ui --timeout=5s >/dev/null 2>&1 || exit 1

# Deployments untouched: spec never edited (generation still 1)
[ "$(kubectl -n metrics-portal get deploy metrics-db -o jsonpath='{.metadata.generation}')" = "1" ] || exit 1
[ "$(kubectl -n metrics-portal get deploy metrics-ui -o jsonpath='{.metadata.generation}')" = "1" ] || exit 1

# The allowed fixes exist
kubectl -n metrics-portal get secret metrics-db-auth -o jsonpath='{.data.POSTGRES_PASSWORD}' | grep -q . || exit 1
[ "$(kubectl -n metrics-portal get pvc metrics-ui-data -o jsonpath='{.status.phase}' 2>/dev/null)" = "Bound" ] || exit 1
PODS_HARD=$(kubectl -n metrics-portal get quota portal-quota -o jsonpath='{.spec.hard.pods}' 2>/dev/null)
[ -n "$PODS_HARD" ] && [ "$PODS_HARD" -ge 2 ] 2>/dev/null || exit 1

exit 0
