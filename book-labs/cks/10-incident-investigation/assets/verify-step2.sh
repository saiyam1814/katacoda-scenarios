#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-10-incident-investigation
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
who=system:serviceaccount:book-cks-incident:actor
can_i no "$who" book-cks-incident get secret/payments
can_i no "$who" book-cks-incident list secrets
can_i no "$who" book-cks-incident delete pods
kubectl -n book-cks-incident get networkpolicy quarantine-actor -o json | json_assert 'd["spec"]["podSelector"]=={} and set(d["spec"]["policyTypes"])=={"Ingress","Egress"} and not d["spec"].get("ingress") and not d["spec"].get("egress")' 'Isolate the affected namespace in both directions'
kubectl -n book-cks-incident get pod actor -o json | json_assert 'd["status"]["phase"]=="Running"' 'Preserve the affected Pod for investigation'
kubectl -n book-cks-incident-control exec observer -- curl -fsS --max-time 2 "http://$(cat "$STATE_DIR/control-web-ip")/" >/dev/null
if kubectl -n book-cks-incident exec actor -- curl -fsS --max-time 2 "http://$(cat "$STATE_DIR/control-web-ip")/" >/dev/null 2>&1;then fail 'Quarantine is not enforced';fi
test -s "$WORK_DIR/containment.yaml"
sha256sum -c "$STATE_DIR/incident-original.sha256"
pass "Step 2: Revoke access and isolate the affected workload"
