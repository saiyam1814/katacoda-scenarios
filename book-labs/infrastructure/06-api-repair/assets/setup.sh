#!/usr/bin/env bash
LAB_ID=infra-06-api-repair
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

setup_begin
api_wait
cp /etc/kubernetes/manifests/kube-apiserver.yaml "$WORK_DIR/kube-apiserver.before.yaml"
k get nodes -o json > "$STATE_DIR/nodes-before.json"
cat > "$WORK_DIR/break.json" <<'EOF'
{"flags":{"client-ca-file":"/etc/kubernetes/pkii/ca.crt"}}
EOF
api_patch "$WORK_DIR/break.json"
for n in $(seq 1 90); do
 if ! k get --raw=/readyz >/dev/null 2>&1; then touch "$STATE_DIR/api-failed"; break; fi
 sleep 2
done
test -f "$STATE_DIR/api-failed" || fail 'Fault injection did not stop API access'
setup_done
