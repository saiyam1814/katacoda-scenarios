#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-10-probes-configuration
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_pod_ready book-cka-config demo-pod
kubectl -n book-cka-config get pod demo-pod -o json | json_assert 'd["spec"]["containers"][0]["envFrom"]==[{"configMapRef":{"name":"demo"}}] and any(e["name"]=="DATABASE_PASSWORD" and e.get("valueFrom",{}).get("secretKeyRef")=={"name":"cka-demo","key":"password"} for e in d["spec"]["containers"][0]["env"]) and any(v.get("configMap",{}).get("name")=="demo" for v in d["spec"]["volumes"])' 'Use references rather than literal values'
kubectl -n book-cka-config exec demo-pod -- sh -c 'test "$colour $name $exam" = "green saiyam cka" && test -n "$DATABASE_PASSWORD" && test "$(cat /etc/config/exam)" = cka'
pass "Step 1: Use ConfigMap and Secret references"
