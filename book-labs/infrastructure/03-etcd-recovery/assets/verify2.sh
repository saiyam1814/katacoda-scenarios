#!/usr/bin/env bash
LAB_ID=infra-03-etcd-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
test -f "$STATE_DIR/deletion-observed" || fail 'Run the real deletion fixture before restoring'
k get --raw=/readyz >/dev/null || fail 'API server is not ready'
k -n cka11 get configmap before-backup -o json > "$STATE_DIR/recovered.json"
python3 - "$STATE_DIR" <<'EOF'
import json,pathlib,sys,yaml
p=pathlib.Path(sys.argv[1]);original=json.loads((p/'original.json').read_text());now=json.loads((p/'recovered.json').read_text())
if now['metadata']['uid']!=original['metadata']['uid'] or now['data'].get('message')!='restore-me':sys.exit('FAIL: original ConfigMap UID and value were not restored')
m=yaml.safe_load(pathlib.Path('/etc/kubernetes/manifests/etcd.yaml').read_text())
if not any(v['name']=='etcd-data' and v['hostPath']['path']=='/var/lib/etcd-cka11-restored' for v in m['spec']['volumes']):sys.exit('FAIL: etcd does not reference the restored host directory')
EOF
if k -n cka11 get configmap after-backup >/dev/null 2>&1; then fail 'Post-snapshot data survived; cluster was not restored to the snapshot'; fi
etcd endpoint status -w json | json_check 'd[0]["Status"]["header"]["revision"] >= 1000000000' 'Restored etcd is missing the revision bump'
pass 'Original object UID recovered, later data removed, restored etcd is healthy with a bumped revision'
