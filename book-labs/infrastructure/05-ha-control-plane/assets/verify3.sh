#!/usr/bin/env bash
LAB_ID=infra-05-ha-control-plane
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
export KUBECONFIG="$WORK_DIR/kubeconfig"
test -s "$STATE_DIR/outage-write" || fail 'Complete the actual failure/write test first'
bash "$ASSET_DIR/verify1.sh"
[[ "$(k -n cka27-check get configmap live-quorum-check -o jsonpath='{.data.value}')" == "$(cat "$STATE_DIR/outage-write")" ]] || fail 'Outage write is missing after recovery'
id=$(docker exec book-ha-control-plane crictl ps --name etcd -q | head -1)
docker exec book-ha-control-plane crictl exec "$id" etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key endpoint health --cluster >/dev/null
pass 'All members recovered and the outage write persisted'
