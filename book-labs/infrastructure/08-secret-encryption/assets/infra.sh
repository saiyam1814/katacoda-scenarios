#!/usr/bin/env bash
set -Eeuo pipefail
: "${LAB_ID:?}"
ASSET_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${BOOK_LAB_STATE_ROOT:-/tmp/book-labs}/$LAB_ID"
WORK_DIR="${BOOK_LAB_WORK_ROOT:-/root/book-labs}/$LAB_ID"
mkdir -p "$STATE_DIR" "$WORK_DIR"
export KUBECONFIG="${KUBECONFIG:-/etc/kubernetes/admin.conf}"
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$*"; }
k() { kubectl --request-timeout=4s "$@"; }
setup_begin() {
 test "$(id -u)" = 0 || fail 'This host exercise requires the disposable VM root shell.'
 rm -f "$STATE_DIR/ready" "$STATE_DIR/error"
 trap 'rc=$?; printf "Setup failed, exit %s at line %s; inspect %s/setup.log\n" "$rc" "$LINENO" "$STATE_DIR" > "$STATE_DIR/error"; exit "$rc"' ERR
 exec > >(tee "$STATE_DIR/setup.log") 2>&1
 if ! python3 -c 'import yaml' 2>/dev/null; then
  timeout 180 apt-get update -qq
  DEBIAN_FRONTEND=noninteractive timeout 180 apt-get install -y -qq python3-yaml
 fi
}
setup_done() { touch "$STATE_DIR/ready"; trap - ERR; printf 'Ready: %s\n' "$LAB_ID"; }
require_ready() { test -f "$STATE_DIR/ready" || fail "Setup is incomplete. Inspect $STATE_DIR/setup.log"; }
api_wait() { python3 "$ASSET_DIR/controlplane.py" ready "${1:-180}"; }
api_id() { crictl ps --name kube-apiserver -q | head -n 1; }
api_patch() {
 local before after
 before=$(sha256sum /etc/kubernetes/manifests/kube-apiserver.yaml | awk '{print $1}')
 python3 "$ASSET_DIR/controlplane.py" patch "$1"
 after=$(sha256sum /etc/kubernetes/manifests/kube-apiserver.yaml | awk '{print $1}')
 API_PATCH_CHANGED=1
 if [[ "$before" == "$after" ]]; then API_PATCH_CHANGED=0; fi
}
api_replace_wait() {
 if [[ "${API_PATCH_CHANGED:-1}" == 0 ]]; then api_wait "${2:-180}"
 else python3 "$ASSET_DIR/controlplane.py" replacement "$1" "${2:-180}"; fi
}
ns() {
 k create namespace "$1" --dry-run=client -o yaml | k apply -f -
 for n in $(seq 1 60); do
  if k -n "$1" get serviceaccount default >/dev/null 2>&1; then return 0; fi
  sleep 1
 done
 fail "Default ServiceAccount controller did not initialize namespace $1"
}
ready_pod() { kubectl -n "$1" wait --for=condition=Ready "pod/$2" --timeout=180s; }
remote() { timeout 15 ssh -o BatchMode=yes -o ConnectTimeout=5 node01 "$@"; }
json_check() { python3 -c 'import json,sys
try:
 d=json.load(sys.stdin); valid=eval(sys.argv[1],{"__builtins__":{"all":all,"any":any,"len":len,"set":set,"sorted":sorted,"int":int}}, {"d":d})
except Exception as e:
 print("FAIL: "+sys.argv[2]+" ("+type(e).__name__+")",file=sys.stderr);sys.exit(1)
if not valid: print("FAIL: "+sys.argv[2],file=sys.stderr);sys.exit(1)
' "$1" "$2"; }
etcd_id() { crictl ps --name etcd -q | head -n 1; }
etcd() { local id; id=$(etcd_id); test -n "$id" || fail 'No running etcd container'; timeout 5 crictl exec "$id" etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key "$@"; }
