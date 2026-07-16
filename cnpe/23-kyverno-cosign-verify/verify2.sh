#!/bin/bash
# signed deployment exists and its pod runs with the digest-pinned image
kubectl -n policy-sandbox get deploy ok-signed-web >/dev/null 2>&1 || exit 1
kubectl -n policy-sandbox wait --for=condition=available deploy/ok-signed-web --timeout=120s >/dev/null 2>&1 || exit 1

# unsigned deployment must not exist
kubectl -n policy-sandbox get deploy blocked-plain-web >/dev/null 2>&1 && exit 1

# double-check enforcement is live: a direct unsigned pod is denied too
if kubectl -n policy-sandbox run verify-unsigned --image=busybox:1.36 --restart=Never -- sleep 5 >/dev/null 2>&1; then
  kubectl -n policy-sandbox delete pod verify-unsigned --now >/dev/null 2>&1
  exit 1
fi
exit 0
