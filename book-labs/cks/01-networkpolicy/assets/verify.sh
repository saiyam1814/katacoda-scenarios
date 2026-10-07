#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-01-networkpolicy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
for pair in 'book-cks-green green' 'book-cks-blue blue'; do
  read -r namespace team <<< "$pair"
  test "$(kubectl get ns "$namespace" -o jsonpath='{.metadata.labels.team}')" = "$team" || fail 'Do not change namespace labels'
done
for pair in 'book-cks-green trusted trusted' 'book-cks-green untrusted untrusted' 'book-cks-blue trusted trusted'; do
  read -r namespace pod access <<< "$pair"
  ready_pod "$namespace" "$pod"
  test "$(kubectl -n "$namespace" get pod "$pod" -o jsonpath='{.metadata.labels.access}')" = "$access" || fail 'Do not change client labels'
done
for app in api admin; do
  ready_deploy book-cks-network "$app"
  kubectl -n book-cks-network get deployment "$app" -o json | json_assert 'len(d["spec"]["template"]["spec"]["containers"]) == 1 and d["spec"]["template"]["spec"]["containers"][0]["image"] == "nginx:1.28.0" and not d["spec"]["template"]["spec"]["containers"][0].get("command") and not d["spec"]["template"]["spec"]["containers"][0].get("args")' 'Do not change the server application'
  kubectl -n book-cks-network get service "$app" -o json | python3 -c 'import json,sys; s=json.load(sys.stdin)["spec"]; assert s["selector"]=={"app":sys.argv[1]} and len(s["ports"])==1 and s["ports"][0]["port"]==80 and s["ports"][0]["targetPort"]==80' "$app"
done
api_ip=$(kubectl -n book-cks-network get svc api -o jsonpath='{.spec.clusterIP}')
admin_ip=$(kubectl -n book-cks-network get svc admin -o jsonpath='{.spec.clusterIP}')
# Give the dataplane time to observe policy updates.
allowed=no
for attempt in $(seq 1 20); do
  if kubectl -n book-cks-green exec trusted -- wget -T 2 -qO- "http://$api_ip" >"$STATE_DIR/allowed" 2>/dev/null; then allowed=yes; break; fi
  sleep 1
done
[[ "$allowed" == yes ]] || fail 'Green trusted client must reach the API'
[[ "$(cat "$STATE_DIR/allowed")" == *'Welcome to nginx!'* ]] || fail 'Unexpected API response'
# Check both source dimensions independently. Each probe runs twice to reduce propagation races.
for pair in "book-cks-green untrusted $api_ip" "book-cks-blue trusted $api_ip" "book-cks-green trusted $admin_ip"; do
  read -r namespace pod ip <<< "$pair"
  for attempt in 1 2; do
    if kubectl -n "$namespace" exec "$pod" -- wget -T 3 -qO- "http://$ip" >"$STATE_DIR/denied" 2>&1; then fail "$namespace/$pod can reach $ip but must be denied"; fi
    # Prove exec itself works; an unavailable Pod cannot count as a denied network connection.
    kubectl -n "$namespace" exec "$pod" -- true || fail 'Probe failed because exec is unavailable'
  done
done
pass "All checks passed for cks-01-networkpolicy"
