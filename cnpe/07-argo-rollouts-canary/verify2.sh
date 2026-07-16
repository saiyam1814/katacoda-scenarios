#!/bin/bash
# Rollout updated to nginx:1.26 and fully promoted
IMG=$(kubectl -n release-bay get rollout media-proxy -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
[ "$IMG" = "nginx:1.26" ] || exit 1

PHASE=$(kubectl -n release-bay get rollout media-proxy -o jsonpath='{.status.phase}')
[ "$PHASE" = "Healthy" ] || exit 1

# Fully promoted: stable == canary revision, weight back to 100/0
STABLE=$(kubectl -n release-bay get rollout media-proxy -o jsonpath='{.status.stableRS}')
CURRENT=$(kubectl -n release-bay get rollout media-proxy -o jsonpath='{.status.currentPodHash}')
[ -n "$STABLE" ] && [ "$STABLE" = "$CURRENT" ] || exit 1

# Legacy deployment scaled down
[ "$(kubectl -n release-bay get deploy media-proxy -o jsonpath='{.spec.replicas}')" = "0" ] || exit 1

exit 0
