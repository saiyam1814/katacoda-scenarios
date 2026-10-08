#!/usr/bin/env bash
LAB_ID=infra-07-apiserver-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
install -m 0600 "$ASSET_DIR/audit-policy.yaml" /etc/kubernetes/audit/policy.yaml
cat > "$WORK_DIR/audit-patch.json" <<'EOF'
{"flags":{"audit-policy-file":"/etc/kubernetes/audit/policy.yaml","audit-log-path":"/var/log/kubernetes/audit/audit.log","audit-log-maxage":"30","audit-log-maxbackup":"10","audit-log-maxsize":"100","audit-log-mode":"blocking"},"mounts":[{"name":"audit-policy","path":"/etc/kubernetes/audit"},{"name":"audit-logs","path":"/var/log/kubernetes/audit","readOnly":false,"type":"DirectoryOrCreate"}]}
EOF
old=$(api_id); test -n "$old"
api_patch "$WORK_DIR/audit-patch.json"
api_replace_wait "$old"
k -n cks06 create deployment web --image=nginx:1.28.0-alpine --dry-run=client -o yaml | k apply -f -
k -n cks06 create secret generic marker --from-literal=token=cks06-sensitive-marker --dry-run=client -o yaml | k apply -f -
bash "$ASSET_DIR/verify1.sh"
