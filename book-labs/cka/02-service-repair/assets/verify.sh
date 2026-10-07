#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-02-service-repair
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
test "$(kubectl -n book-cka-service get svc web -o jsonpath='{.spec.clusterIP}')" = "$(cat "$STATE_DIR/service-ip")" || fail 'Preserve the Service ClusterIP'
kubectl -n book-cka-service get service web -o json | json_assert 'd["spec"]["selector"] == {"app":"web"} and len(d["spec"]["ports"]) == 1 and d["spec"]["ports"][0]["port"] == 80 and d["spec"]["ports"][0]["targetPort"] == 80' 'Service selector or port is still wrong'
ready_deploy book-cka-service web
kubectl -n book-cka-service get endpointslices -l kubernetes.io/service-name=web -o json | json_assert 'any(e.get("conditions",{}).get("ready") is True for s in d["items"] for e in s.get("endpoints",[]))' 'No Ready endpoints'
body=''
for attempt in $(seq 1 20); do
  if body=$(kubectl -n book-cka-service exec client -- wget -T 3 -qO- http://web 2>"$STATE_DIR/http-error"); then break; fi
  sleep 1
done
[[ "$body" == *'Welcome to nginx!'* ]] || fail 'Service did not return the expected application' 
pass "All checks passed for cka-02-service-repair"
