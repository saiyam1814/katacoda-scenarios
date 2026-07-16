#!/bin/bash
# Denied ones must not exist
kubectl -n tag-lab get deploy floating-latest >/dev/null 2>&1 && exit 1
kubectl -n tag-lab get deploy missing-tag >/dev/null 2>&1 && exit 1

# Pinned one exists
kubectl -n tag-lab get deploy pinned-ok >/dev/null 2>&1 || exit 1
IMG=$(kubectl -n tag-lab get deploy pinned-ok -o jsonpath='{.spec.template.spec.containers[0].image}')
[ "$IMG" = "busybox:1.36.1" ] || exit 1

# And the webhook is really enforcing (belt & suspenders: try latest once more)
if kubectl -n tag-lab create deploy verify-should-fail --image=nginx:latest >/dev/null 2>&1; then
  kubectl -n tag-lab delete deploy verify-should-fail >/dev/null 2>&1
  exit 1
fi
exit 0
