#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-02-service-repair
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_deploy_ready book-cka-incident web
kubectl -n book-cka-incident get deployment web -o json | json_assert 'd["spec"]["replicas"]==2 and d["spec"]["template"]["spec"]["containers"][0]["image"]=="nginx:1.28.0" and d["spec"]["template"]["spec"]["containers"][0]["envFrom"]==[{"configMapRef":{"name":"app-config"}}] and d["spec"]["template"]["spec"]["containers"][0]["resources"]["requests"]=={"cpu":"100m","memory":"64Mi"} and d["spec"]["template"]["spec"]["containers"][0]["resources"]["limits"]["memory"]=="128Mi"' 'Restore the requested workload specification'
kubectl -n book-cka-incident get svc web -o json | json_assert 'd["spec"]["ports"][0]["targetPort"]=="http"' 'Use the named target port'
kubectl -n book-cka-incident get endpointslices -l kubernetes.io/service-name=web -o json | json_assert 'len([e for s in d["items"] for e in s.get("endpoints",[]) if e.get("conditions",{}).get("ready")])==2' 'Require two Ready endpoints'
body=$(kubectl -n book-cka-incident exec client -- wget -qO- -T 2 http://web.book-cka-incident.svc.cluster.local)
[[ "$body" == *'Welcome to nginx!'* ]] || fail 'HTTP still fails'
for term in memory image ConfigMap targetPort; do grep -qi "$term" "$WORK_DIR/incident.txt" || fail "Explain the $term fault"; done
pass "Step 2: Recover a workload through events and endpoints"
