#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-02-service-repair
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-service get svc web -o json | json_assert 'd["spec"]["selector"]=={"app":"web"} and d["spec"]["ports"][0]["targetPort"]==80' 'Service selector or target port is incorrect'
kubectl -n book-cka-service get pod client -o json | json_assert 'd["spec"]["dnsPolicy"]=="ClusterFirst" and not d["spec"].get("dnsConfig",{}).get("nameservers")' 'Restore the client resolver'
kubectl -n book-cka-service exec client -- nslookup web.book-cka-service.svc.cluster.local >/dev/null
body=$(kubectl -n book-cka-service exec client -- wget -qO- -T 2 http://web.book-cka-service.svc.cluster.local)
[[ "$body" == *'Welcome to nginx!'* ]] || fail 'Real HTTP request failed'
test -s "$WORK_DIR/causes.txt" || fail 'Write the incident diagnosis'
for term in selector 8080 DNS; do grep -qi "$term" "$WORK_DIR/causes.txt" || fail "Diagnosis must explain $term"; done
pass "Step 1: Repair the Service and client resolver"
