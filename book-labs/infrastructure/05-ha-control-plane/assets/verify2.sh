#!/usr/bin/env bash
LAB_ID=infra-05-ha-control-plane
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
export KUBECONFIG="$WORK_DIR/kubeconfig"
[[ "$(docker inspect -f '{{.State.Running}}' book-ha-control-plane)" == false ]] || fail 'The first control plane must be stopped for the failure test'
for node in book-ha-control-plane2 book-ha-control-plane3 book-ha-external-load-balancer; do
 [[ "$(docker inspect -f '{{.State.Running}}' "$node")" == true ]] || fail "Required survivor is stopped: $node"
done
ns cka27-check
nonce=$(python3 -c 'import uuid;print(uuid.uuid4().hex)')
k -n cka27-check create configmap live-quorum-check --from-literal=value="$nonce" --dry-run=client -o yaml | k apply -f -
[[ "$(k -n cka27-check get configmap live-quorum-check -o jsonpath='{.data.value}')" == "$nonce" ]] || fail 'Write/read failed while the first member was unavailable'
printf '%s\n' "$nonce" > "$STATE_DIR/outage-write"
pass 'Fresh API write and read succeeded through the load balancer with one member stopped'
