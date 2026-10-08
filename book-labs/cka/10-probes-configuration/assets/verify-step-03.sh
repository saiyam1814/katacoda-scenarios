#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-10-probes-configuration
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_deploy_ready book-cka-probes web
kubectl -n book-cka-probes get deployment web -o json | json_assert 'd["spec"]["replicas"]==2 and d["spec"]["template"]["spec"]["containers"][0].get("startupProbe",{}).get("httpGet")=={"path":"/","port":"http","scheme":"HTTP"} and d["spec"]["template"]["spec"]["containers"][0].get("readinessProbe",{}).get("httpGet")=={"path":"/","port":"http","scheme":"HTTP"} and d["spec"]["template"]["spec"]["containers"][0].get("livenessProbe",{}).get("httpGet")=={"path":"/","port":"http","scheme":"HTTP"} and d["spec"]["template"]["spec"]["containers"][0]["resources"]=={"requests":{"cpu":"100m","memory":"64Mi"},"limits":{"cpu":"300m","memory":"128Mi"}} and d["spec"]["template"]["spec"]["affinity"]["nodeAffinity"]["requiredDuringSchedulingIgnoredDuringExecution"]["nodeSelectorTerms"][0]["matchExpressions"][0]=={"key":"book-labs.example/pool","operator":"In","values":["apps"]} and any(t.get("key")=="book-labs.example/pool" and t.get("value")=="apps" and t.get("effect")=="NoSchedule" for t in d["spec"]["template"]["spec"].get("tolerations",[]))' 'Require the requested probes, resource settings and placement constraints'
kubectl -n book-cka-probes get limitrange container-limits -o json | json_assert 'any(x["type"]=="Container" and x.get("max",{}).get("memory")=="256Mi" for x in d["spec"]["limits"])' 'Enforce the exact256Mi per-container maximum'
if kubectl -n book-cka-probes run too-large --image=nginx:1.28.0 --dry-run=server --overrides='{"spec":{"containers":[{"name":"web","image":"nginx:1.28.0","resources":{"requests":{"memory":"64Mi"},"limits":{"memory":"512Mi"}}}]}}' >"$STATE_DIR/admission-check" 2>&1; then fail 'Oversized Pod was admitted'; fi
grep -q 'maximum memory usage per Container' "$STATE_DIR/admission-check" || fail 'Failure was not the intended LimitRange rejection'
pass "Step 3: Combine probes, affinity, toleration and resource admission"
