#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-05-scheduling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_pod_ready book-cka-scheduling near-anchor
kubectl -n book-cka-scheduling get pod near-anchor -o json | json_assert 'd["spec"]["affinity"]["podAffinity"]["requiredDuringSchedulingIgnoredDuringExecution"]==[{"labelSelector":{"matchLabels":{"role":"anchor"}},"topologyKey":"kubernetes.io/hostname"}] and not d["spec"].get("nodeSelector")' 'Require Pod affinity on the host topology'
test "$(kubectl -n book-cka-scheduling get pod anchor -o jsonpath='{.spec.nodeName}')" = "$(kubectl -n book-cka-scheduling get pod near-anchor -o jsonpath='{.spec.nodeName}')" || fail 'Pods are not co-located'
uid=$(kubectl -n book-cka-scheduling get pod near-anchor -o jsonpath='{.metadata.uid}')
kubectl -n book-cka-scheduling get events --field-selector "involvedObject.uid=$uid,reason=Scheduled" -o json | json_assert 'len(d["items"])>0' 'Do not bypass the scheduler'
pass "Step 3: Co-locate using required Pod affinity"
