#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-05-scheduling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_pod_ready book-cka-scheduling reporter
kubectl -n book-cka-scheduling get pod reporter -o json | json_assert 'd["spec"]["nodeSelector"]=={"book-labs.example/disk":"ssd"} and d["spec"]["containers"][0]["image"]=="busybox:1.37.0"' 'Keep requested selector and image'
uid=$(kubectl -n book-cka-scheduling get pod reporter -o jsonpath='{.metadata.uid}')
kubectl -n book-cka-scheduling get events --field-selector "involvedObject.uid=$uid,reason=Scheduled" -o json | json_assert 'len(d["items"])>0' 'Current Pod must have a Scheduled event'
node=$(kubectl -n book-cka-scheduling get pod reporter -o jsonpath='{.spec.nodeName}')
kubectl get node "$node" -o json | json_assert 'd["metadata"]["labels"].get("book-labs.example/disk")=="ssd"' 'Pod runs on the wrong node'
pass "Step 1: Repair a node selector"
