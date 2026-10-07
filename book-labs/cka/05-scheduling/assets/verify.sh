#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-05-scheduling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-scheduling get pod reporter -o json | json_assert 'd["spec"]["nodeSelector"].get("book-labs.example/disk") == "ssd" and d["spec"]["containers"][0]["image"] == "busybox:1.37.0" and d["spec"]["containers"][0]["command"] == ["sh","-c","sleep 3600"]' 'Keep the requested node selector and container'
ready_pod book-cka-scheduling reporter
node=$(kubectl -n book-cka-scheduling get pod reporter -o jsonpath='{.spec.nodeName}')
kubectl get node "$node" -o json | json_assert 'd["metadata"]["labels"].get("book-labs.example/disk") == "ssd"' 'Pod is not running on the labeled node'
pod_uid=$(kubectl -n book-cka-scheduling get pod reporter -o jsonpath='{.metadata.uid}')
kubectl -n book-cka-scheduling get events --field-selector "involvedObject.uid=$pod_uid,reason=Scheduled" -o json | json_assert 'len(d["items"]) > 0' 'No scheduler Scheduled event for the current Pod UID: do not bypass scheduling with nodeName' 
pass "All checks passed for cka-05-scheduling"
