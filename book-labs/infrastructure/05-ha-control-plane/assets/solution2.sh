#!/usr/bin/env bash
LAB_ID=infra-05-ha-control-plane
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
export KUBECONFIG="$WORK_DIR/kubeconfig"
bash "$ASSET_DIR/verify1.sh"
docker stop book-ha-control-plane
# Wait outside CHECK while load-balancer health checks and etcd leadership converge.
api_wait 90
ns cka27-check
k -n cka27-check create configmap quorum-check --from-literal=works=yes
bash "$ASSET_DIR/verify2.sh"
