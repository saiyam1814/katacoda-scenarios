#!/usr/bin/env bash
LAB_ID=infra-07-apiserver-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
install -m 0600 "$ASSET_DIR/webhook-kubeconfig" /etc/kubernetes/image-policy/kubeconfig
install -m 0600 "$ASSET_DIR/webhook-admission.yaml" /etc/kubernetes/image-policy/admission.yaml
cat > "$WORK_DIR/webhook-patch.json" <<'EOF'
{"flags":{"admission-control-config-file":"/etc/kubernetes/image-policy/admission.yaml"},"append":{"enable-admission-plugins":["ImagePolicyWebhook"],"runtime-config":["imagepolicy.k8s.io/v1alpha1=true"]},"mounts":[{"name":"image-policy","path":"/etc/kubernetes/image-policy"}]}
EOF
old=$(api_id); test -n "$old"
api_patch "$WORK_DIR/webhook-patch.json"
api_replace_wait "$old"
k -n cks16 run allowed --image=busybox:1.37.0 --restart=Never --dry-run=client -o yaml --command -- sleep 3600 | k apply -f -
ready_pod cks16 allowed
bash "$ASSET_DIR/verify2.sh"
