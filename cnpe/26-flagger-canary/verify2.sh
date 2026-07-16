#!/bin/bash
# canary fully promoted
PHASE=$(kubectl -n release-bay get canary media-proxy -o jsonpath='{.status.phase}' 2>/dev/null)
[ "$PHASE" = "Succeeded" ] || exit 1

# primary now runs the new image
IMG=$(kubectl -n release-bay get deploy media-proxy-primary -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
[ "$IMG" = "nginx:1.26" ] || exit 1

# primary healthy
kubectl -n release-bay wait --for=condition=available deploy/media-proxy-primary --timeout=10s >/dev/null 2>&1 || exit 1
exit 0
