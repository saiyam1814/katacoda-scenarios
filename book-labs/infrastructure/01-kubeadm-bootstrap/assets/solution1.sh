#!/usr/bin/env bash
LAB_ID=infra-01-kubeadm-bootstrap
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
bash "$ASSET_DIR/build-cluster.sh" 1.35 1.35.9
ns cka01
for node in controlplane node01; do
 cat <<EOF | k apply -f -
apiVersion: v1
kind: Pod
metadata: {name: dns-$node, namespace: cka01}
spec:
  nodeSelector: {kubernetes.io/hostname: $node}
  tolerations:
  - {key: node-role.kubernetes.io/control-plane, operator: Exists, effect: NoSchedule}
  containers:
  - name: dns
    image: busybox:1.37.0
    command: [sleep, '3600']
EOF
 ready_pod cka01 "dns-$node"
done
bash "$ASSET_DIR/verify1.sh"
