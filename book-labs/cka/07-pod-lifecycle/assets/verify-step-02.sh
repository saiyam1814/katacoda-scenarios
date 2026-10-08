#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-07-pod-lifecycle
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_pod_ready book-cka-pods init-web
kubectl -n book-cka-pods get pod init-web -o json | json_assert 'd["spec"]["initContainers"][0]["name"]=="sam-init" and d["status"]["initContainerStatuses"][0]["state"]["terminated"]["exitCode"]==0 and any("emptyDir" in v for v in d["spec"]["volumes"])' 'Init container must complete with a shared emptyDir'
test "$(kubectl -n book-cka-pods exec init-web -c web -- curl -fsS http://localhost)" = "hello world" || fail "Wrong HTTP body"
pass "Step 2: Prepare the web root with an init container"
