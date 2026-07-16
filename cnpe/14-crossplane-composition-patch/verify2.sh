#!/bin/bash
# XR exists and is Ready
kubectl get xwebapp demo-site >/dev/null 2>&1 || exit 1
READY=$(kubectl get xwebapp demo-site -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
[ "$READY" = "True" ] || exit 1

# Composed Deployment with patched values
[ "$(kubectl -n compose-sandbox get deploy demo-site -o jsonpath='{.spec.replicas}' 2>/dev/null)" = "2" ] || exit 1
IMG=$(kubectl -n compose-sandbox get deploy demo-site -o jsonpath='{.spec.template.spec.containers[0].image}')
[ "$IMG" = "nginx:1.25" ] || exit 1
[ "$(kubectl -n compose-sandbox get deploy demo-site -o jsonpath='{.spec.selector.matchLabels.app}')" = "demo-site" ] || exit 1

# Composed Service
kubectl -n compose-sandbox get svc demo-site >/dev/null 2>&1 || exit 1

# Deployment actually running
kubectl -n compose-sandbox wait --for=condition=available deploy/demo-site --timeout=10s >/dev/null 2>&1 || exit 1

exit 0
