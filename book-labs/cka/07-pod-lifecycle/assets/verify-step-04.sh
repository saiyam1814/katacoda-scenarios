#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-07-pod-lifecycle
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_pod_ready book-cka-pods log-demo
kubectl -n book-cka-pods get pod log-demo -o json | json_assert 'd["spec"]["initContainers"][0]["name"]=="log-reader" and d["spec"]["initContainers"][0].get("restartPolicy")=="Always" and "running" in d["status"]["initContainerStatuses"][0]["state"]' 'Use a running native sidecar'
kubectl -n book-cka-pods logs log-demo -c log-reader --tail=5 | grep -q "learning Kubernetes" || fail "Sidecar did not consume the shared log"
pass "Step 4: Use a native sidecar for shared logs"
