#!/usr/bin/env bash
set -Eeuo pipefail
: "${LAB_ID:?LAB_ID is required}"
STATE_DIR="${BOOK_LAB_STATE_ROOT:-/tmp/book-labs}/$LAB_ID"
WORK_DIR="${BOOK_LAB_WORK_ROOT:-$HOME/book-labs}/$LAB_ID"
mkdir -p "$STATE_DIR" "$WORK_DIR"
fail() { printf 'FAIL: %s\n' "$*" >&2; if [[ ${SETUP_ACTIVE:-0} == 1 ]]; then printf 'Setup failed: %s\n' "$*" > "$STATE_DIR/error"; fi; exit 1; }
pass() { printf 'PASS: %s\n' "$*"; }
require_tools() { for tool in kubectl python3; do command -v "$tool" >/dev/null || fail "Required command missing: $tool"; done; }
setup_begin() {
  SETUP_ACTIVE=1
  require_tools
  rm -f "$STATE_DIR/ready" "$STATE_DIR/error"
  trap 'code=$?; printf "Setup failed (exit %s, line %s). Read %s/setup.log\n" "$code" "$LINENO" "$STATE_DIR" > "$STATE_DIR/error"; exit "$code"' ERR
  exec > >(tee "$STATE_DIR/setup.log") 2>&1
  # A process timeout also bounds discovery/credential-plugin hangs. The entire
  # preflight is capped at 180 seconds, below the 480-second foreground wait.
  if ! python3 - <<'PYREADY'
import os, subprocess, sys, time
budget = max(1.0, min(180.0, float(os.environ.get("BOOK_LAB_API_TIMEOUT_SECONDS", "180"))))
deadline = time.monotonic() + budget
while (remaining := deadline - time.monotonic()) > 0:
    try:
        result = subprocess.run(
            ["kubectl", "--request-timeout=5s", "get", "--raw=/readyz"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
            timeout=min(5.0, remaining),
        )
        if result.returncode == 0:
            sys.exit(0)
    except subprocess.TimeoutExpired:
        pass
    remaining = deadline - time.monotonic()
    if remaining > 0:
        time.sleep(min(2.0, remaining))
sys.exit(1)
PYREADY
  then
    fail 'Kubernetes API readiness timed out (preflight budget is at most 180 seconds)'
  fi
}
setup_done() { SETUP_ACTIVE=0; touch "$STATE_DIR/ready"; trap - ERR; printf 'Ready: %s\n' "$LAB_ID"; }
require_ready() { require_tools; test -f "$STATE_DIR/ready" || fail "Run setup.sh first; inspect $STATE_DIR/setup.log"; }
ns() { kubectl create namespace "$1" --dry-run=client -o yaml | kubectl apply -f -; }
# Resets only a uniquely named lab namespace. Never run these labs on production.
reset_ns() { kubectl delete namespace "$1" --ignore-not-found --wait=true --timeout=90s; ns "$1"; }
ready_pod() { kubectl -n "$1" wait --for=condition=Ready "pod/$2" --timeout=120s; }
ready_deploy() { kubectl -n "$1" rollout status "deployment/$2" --timeout=120s; }
can_i() {
  local expected=$1 identity=$2 namespace=$3 verb=$4 resource=$5 result rc=0
  local sa_namespace="${identity#system:serviceaccount:}"
  sa_namespace="${sa_namespace%%:*}"
  result=$(kubectl --request-timeout=10s auth can-i "$verb" "$resource" -n "$namespace" --as="$identity" --as-group=system:serviceaccounts --as-group="system:serviceaccounts:$sa_namespace" --as-group=system:authenticated 2>"$STATE_DIR/auth-error") || rc=$?
  if [[ "$result" != "$expected" ]]; then cat "$STATE_DIR/auth-error" >&2; fail "$identity $verb $resource in $namespace: expected $expected, got $result (exit $rc)"; fi
  if [[ "$expected" == yes && $rc -ne 0 ]] || [[ "$expected" == no && $rc -ne 1 ]]; then fail "Unexpected authorization command error $rc"; fi
}
# Inspect semantic JSON, never textual matches for resource status.
json_assert() { python3 -c 'import json,sys; d=json.load(sys.stdin); assert eval(sys.argv[1], {"__builtins__": {"all":all,"any":any,"len":len,"set":set,"sorted":sorted,"int":int}}, {"d":d}), sys.argv[2]' "$1" "$2"; }

# A successful rollout can leave old Pods terminating; never inspect .items[0].
one_ready_pod() {
  kubectl -n "$1" get pods -l "$2" -o json | python3 -c 'import json,sys; items=json.load(sys.stdin)["items"]; pods=[p for p in items if not p["metadata"].get("deletionTimestamp") and p.get("status",{}).get("phase")=="Running" and any(c["type"]=="Ready" and c["status"]=="True" for c in p.get("status",{}).get("conditions",[]))]; assert len(pods)==1, "Expected exactly one current Ready Pod"; print(pods[0]["metadata"]["name"])'
}
