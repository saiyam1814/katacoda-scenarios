#!/bin/bash
# HPA must be reading live metrics (not <unknown>)
CUR=$(kubectl -n edge-web get hpa storefront -o jsonpath='{.status.currentMetrics[?(@.resource.name=="cpu")].resource.current.averageUtilization}' 2>/dev/null)
[ -n "$CUR" ] || exit 1

# Evidence of a scale event: either currently >2 replicas, or desired >2 at some point (ScalingLimited/AbleToScale events), or currently scaled
DESIRED=$(kubectl -n edge-web get hpa storefront -o jsonpath='{.status.desiredReplicas}')
CURRENT=$(kubectl -n edge-web get hpa storefront -o jsonpath='{.status.currentReplicas}')
if [ "${DESIRED:-0}" -gt 2 ] || [ "${CURRENT:-0}" -gt 2 ]; then
  exit 0
fi
# Fallback: a SuccessfulRescale event happened
kubectl -n edge-web get events --field-selector reason=SuccessfulRescale 2>/dev/null | grep -q storefront && exit 0
exit 1
