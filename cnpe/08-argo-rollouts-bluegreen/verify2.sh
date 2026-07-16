#!/bin/bash
# Rollout on green, healthy, promoted
IMG=$(kubectl -n shop-core get rollout catalog -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
[ "$IMG" = "nginx:1.26" ] || exit 1
[ "$(kubectl -n shop-core get rollout catalog -o jsonpath='{.status.phase}')" = "Healthy" ] || exit 1

STABLE=$(kubectl -n shop-core get rollout catalog -o jsonpath='{.status.stableRS}')
CURRENT=$(kubectl -n shop-core get rollout catalog -o jsonpath='{.status.currentPodHash}')
[ -n "$STABLE" ] && [ "$STABLE" = "$CURRENT" ] || exit 1

# active service selector points at the promoted (green) hash
ACTIVE_HASH=$(kubectl -n shop-core get svc catalog-active -o jsonpath='{.spec.selector.rollouts-pod-template-hash}')
[ "$ACTIVE_HASH" = "$CURRENT" ] || exit 1

# legacy deployment retired
[ "$(kubectl -n shop-core get deploy catalog -o jsonpath='{.spec.replicas}')" = "0" ] || exit 1

exit 0
