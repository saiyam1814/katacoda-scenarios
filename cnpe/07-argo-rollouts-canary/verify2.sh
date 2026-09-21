#!/bin/bash
# Rollout updated to nginx:1.26 and fully promoted
IMG=$(kubectl -n release-bay get deployment media-proxy -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
[ "$IMG" = "nginx:1.26" ] || exit 1

PHASE=$(kubectl -n release-bay get rollout media-proxy -o jsonpath='{.status.phase}')
[ "$PHASE" = "Healthy" ] || exit 1

# Fully promoted: stable == canary revision, weight back to 100/0
STABLE=$(kubectl -n release-bay get rollout media-proxy -o jsonpath='{.status.stableRS}')
CURRENT=$(kubectl -n release-bay get rollout media-proxy -o jsonpath='{.status.currentPodHash}')
[ -n "$STABLE" ] && [ "$STABLE" = "$CURRENT" ] || exit 1

# Legacy deployment scaled down
[ "$(kubectl -n release-bay get deploy media-proxy -o jsonpath='{.spec.replicas}')" = "0" ] || exit 1

# Inspect the stable ReplicaSet image, not only the source template.
RS=$(kubectl -n release-bay get rs -l "rollouts-pod-template-hash=$STABLE" -o jsonpath='{.items[0].spec.template.spec.containers[0].image}')
[ "$RS" = "nginx:1.26" ] || exit 1
kubectl -n release-bay get virtualservice media-proxy -o json | python3 -c '
import json,sys
route=next(h for h in json.load(sys.stdin)["spec"]["http"] if h["name"]=="primary")
weights={r["destination"]["host"]:r["weight"] for r in route["route"]}
assert weights["media-proxy-stable"]==100 and weights["media-proxy-canary"]==0
' || exit 1
exit 0
