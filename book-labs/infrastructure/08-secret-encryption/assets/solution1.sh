#!/usr/bin/env bash
LAB_ID=infra-08-secret-encryption
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
umask 077
python3 - <<'EOF'
import base64,os,pathlib,yaml
p=pathlib.Path('/etc/kubernetes/encryption/config.yaml')
if not p.exists():
 config={'apiVersion':'apiserver.config.k8s.io/v1','kind':'EncryptionConfiguration','resources':[{'resources':['secrets'],'providers':[{'aescbc':{'keys':[{'name':'key1','secret':base64.b64encode(os.urandom(32)).decode()}]}},{'identity':{}}]}]}
 p.write_text(yaml.safe_dump(config,sort_keys=False));p.chmod(0o600)
EOF
cat > "$WORK_DIR/encryption-patch.json" <<'EOF'
{"flags":{"encryption-provider-config":"/etc/kubernetes/encryption/config.yaml"},"mounts":[{"name":"encryption","path":"/etc/kubernetes/encryption"}]}
EOF
old=$(api_id); test -n "$old"
api_patch "$WORK_DIR/encryption-patch.json"
api_replace_wait "$old"
k get secrets --all-namespaces -o json | k replace -f -
bash "$ASSET_DIR/verify1.sh"
