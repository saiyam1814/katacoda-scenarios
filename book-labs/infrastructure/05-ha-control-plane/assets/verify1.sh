#!/usr/bin/env bash
LAB_ID=infra-05-ha-control-plane
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
export KUBECONFIG="$WORK_DIR/kubeconfig"
k get nodes -o json | json_check 'len(d["items"])==3 and all("node-role.kubernetes.io/control-plane" in x["metadata"]["labels"] and any(c["type"]=="Ready" and c["status"]=="True" for c in x["status"]["conditions"]) for x in d["items"])' 'All three real control planes must be Ready'
docker exec book-ha-control-plane crictl ps --name etcd -q > "$STATE_DIR/etcd-id"
id=$(head -1 "$STATE_DIR/etcd-id")
test -n "$id" || fail "First control-plane etcd process is not running yet"
docker exec book-ha-control-plane crictl exec "$id" etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key member list -w json | json_check 'len(d["members"])==3 and all(not m.get("isLearner",False) for m in d["members"])' 'Three voting etcd members are required'
docker exec book-ha-control-plane crictl exec "$id" etcdctl --command-timeout=2s --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key endpoint health --cluster >/dev/null
pass 'Three joined control planes and three voting etcd members verified'
