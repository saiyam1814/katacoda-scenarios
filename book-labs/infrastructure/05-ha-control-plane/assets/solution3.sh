#!/usr/bin/env bash
LAB_ID=infra-05-ha-control-plane
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
export KUBECONFIG="$WORK_DIR/kubeconfig"
docker start book-ha-control-plane
# Node Ready can briefly remain stale after restart. Wait for the actual local
# etcd process and successful health checks from every member before grading.
for attempt in $(seq 1 90); do
 id=$(docker exec book-ha-control-plane crictl ps --name etcd -q | head -1)
 if [[ -n "$id" ]] && docker exec book-ha-control-plane crictl exec "$id" etcdctl --command-timeout=3s --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key endpoint health --cluster >/dev/null 2>&1; then break; fi
 sleep 2
done
kubectl wait --for=condition=Ready node --all --timeout=180s
bash "$ASSET_DIR/verify3.sh"
