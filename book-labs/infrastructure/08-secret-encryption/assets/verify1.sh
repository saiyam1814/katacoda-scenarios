#!/usr/bin/env bash
LAB_ID=infra-08-secret-encryption
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
api_value=$(k -n cks25 get secret database -o jsonpath='{.data.password}')
[[ "$(printf '%s' "$api_value" | base64 -d)" == cks25-lab-marker ]] || fail 'API could not decrypt the original Secret value'
etcd get /registry/secrets/cks25/database --print-value-only > "$STATE_DIR/cipher-check.bin"
python3 - "$STATE_DIR/cipher-check.bin" <<'EOF'
import pathlib,sys,stat
p=pathlib.Path('/etc/kubernetes/encryption/config.yaml')
if not p.exists():sys.exit('FAIL: encryption configuration is missing')
if stat.S_IMODE(p.stat().st_mode)!=0o600:sys.exit('FAIL: encryption configuration must have mode 0600')
b=pathlib.Path(sys.argv[1]).read_bytes()
if not b.startswith(b'k8s:enc:aescbc:v1:key1:') or b'cks25-lab-marker' in b:sys.exit('FAIL: actual etcd value is not encrypted with key1')
print('PASS: original Secret is decryptable through API and encrypted in real etcd storage')
EOF
