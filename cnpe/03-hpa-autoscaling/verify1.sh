#!/bin/bash
kubectl -n edge-web get hpa storefront >/dev/null 2>&1 || exit 1

[ "$(kubectl -n edge-web get hpa storefront -o jsonpath='{.spec.minReplicas}')" = "2" ] || exit 1
[ "$(kubectl -n edge-web get hpa storefront -o jsonpath='{.spec.maxReplicas}')" = "8" ] || exit 1
[ "$(kubectl -n edge-web get hpa storefront -o jsonpath='{.spec.scaleTargetRef.kind}')" = "Deployment" ] || exit 1
[ "$(kubectl -n edge-web get hpa storefront -o jsonpath='{.spec.scaleTargetRef.name}')" = "storefront" ] || exit 1

# v2 metric target: 60% CPU utilization (also accept v1 annotation form)
UTIL=$(kubectl -n edge-web get hpa storefront -o jsonpath='{.spec.metrics[?(@.resource.name=="cpu")].resource.target.averageUtilization}' 2>/dev/null)
[ "$UTIL" = "60" ] || exit 1

exit 0
