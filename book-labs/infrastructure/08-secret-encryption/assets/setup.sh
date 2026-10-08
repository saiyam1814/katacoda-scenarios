#!/usr/bin/env bash
LAB_ID=infra-08-secret-encryption
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

setup_begin
api_wait
python3 - <<'EOF'
import pathlib,yaml,sys
m=yaml.safe_load(pathlib.Path('/etc/kubernetes/manifests/kube-apiserver.yaml').read_text())
if any(x.startswith('--encryption-provider-config=') for x in m['spec']['containers'][0]['command']):sys.exit('Fresh environment required: encryption is already configured')
EOF
ns cks25
k -n cks25 create secret generic database --from-literal=password=cks25-lab-marker
mkdir -p /etc/kubernetes/encryption
cp /etc/kubernetes/manifests/kube-apiserver.yaml "$WORK_DIR/kube-apiserver.before.yaml"
etcd endpoint health
etcd get /registry/secrets/cks25/database --print-value-only > "$STATE_DIR/plain-before.bin"
grep -aFq cks25-lab-marker "$STATE_DIR/plain-before.bin" || fail 'Initial etcd Secret was not plaintext as expected'
setup_done
