#!/usr/bin/env bash
LAB_ID=infra-03-etcd-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
if ! test -f "$STATE_DIR/deletion-observed"; then bash "$ASSET_DIR/prepare2.sh"; fi
test ! -e /var/lib/etcd-cka11-restored || fail 'Restored directory already exists; inspect the prior attempt rather than overwriting data'
mkdir -p "$WORK_DIR/stopped-manifests"
for name in kube-apiserver kube-controller-manager kube-scheduler etcd; do mv "/etc/kubernetes/manifests/$name.yaml" "$WORK_DIR/stopped-manifests/"; done
for n in $(seq 1 90); do
 count=$(crictl ps -o json | python3 -c 'import json,sys;print(sum(x["metadata"]["name"] in ["kube-apiserver","kube-controller-manager","kube-scheduler","etcd"] for x in json.load(sys.stdin)["containers"]))')
 if [[ "$count" == 0 ]]; then break; fi
 sleep 2
done
[[ "$count" == 0 ]] || fail 'Wait for all control-plane containers to stop before restore'
python3 - "$WORK_DIR" <<'EOF'
import pathlib,subprocess,sys,yaml
p=pathlib.Path(sys.argv[1]);m=yaml.safe_load((p/'stopped-manifests/etcd.yaml').read_text());flags=dict(x[2:].split('=',1) for x in m['spec']['containers'][0]['command'] if x.startswith('--') and '=' in x)
name=flags['name'];peer=flags['initial-advertise-peer-urls']
subprocess.run([str(p/'bin/etcdutl'),'snapshot','restore','/var/backups/cka11.db','--data-dir=/var/lib/etcd-cka11-restored','--name='+name,'--initial-cluster='+name+'='+peer,'--initial-advertise-peer-urls='+peer,'--initial-cluster-token=cka11-restored','--bump-revision=1000000000','--mark-compacted'],check=True)
for v in m['spec']['volumes']:
 if v['name']=='etcd-data':v['hostPath']['path']='/var/lib/etcd-cka11-restored'
(p/'stopped-manifests/etcd.yaml').write_text(yaml.safe_dump(m,sort_keys=False))
EOF
for name in etcd kube-apiserver kube-controller-manager kube-scheduler; do mv "$WORK_DIR/stopped-manifests/$name.yaml" /etc/kubernetes/manifests/; done
api_wait 240
bash "$ASSET_DIR/verify2.sh"
