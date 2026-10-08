#!/usr/bin/env bash
LAB_ID=infra-03-etcd-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

setup_begin
api_wait
ns cka11
k -n cka11 create configmap before-backup --from-literal=message=restore-me --dry-run=client -o yaml | k apply -f -
k -n cka11 get configmap before-backup -o json > "$STATE_DIR/original.json"
mkdir -p "$WORK_DIR/bin" /var/backups
# Copy the exact running image binaries through its process root; no unrelated
# version download and no dependency on the containerd snapshotter's mount API.
id=$(etcd_id)
pid=$(crictl inspect "$id" | python3 -c 'import json,sys;print(json.load(sys.stdin)["info"]["pid"])')
for binary in etcdctl etcdutl; do
 cp "/proc/$pid/root/usr/local/bin/$binary" "$WORK_DIR/bin/$binary"
 chmod 0755 "$WORK_DIR/bin/$binary"
done
"$WORK_DIR/bin/etcdutl" version
cp /etc/kubernetes/manifests/etcd.yaml "$WORK_DIR/etcd.before.yaml"
setup_done
