#!/usr/bin/env bash
LAB_ID=infra-05-ha-control-plane
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
export KUBECONFIG="$WORK_DIR/kubeconfig"
key=$(docker exec book-ha-control-plane kubeadm init phase upload-certs --upload-certs | tail -n 1)
[[ "$key" =~ ^[a-f0-9]{64}$ ]] || fail 'Could not obtain an uploaded-certificate key'
join=$(docker exec book-ha-control-plane kubeadm token create --print-join-command)
for node in book-ha-control-plane2 book-ha-control-plane3; do
 ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$node")
 # Generated join command contains only kubeadm's current token and CA hash.
 docker exec "$node" bash -c "$join --control-plane --certificate-key $key --apiserver-advertise-address $ip"
 kubectl wait --for=condition=Ready "node/$node" --timeout=180s
done
unset key join
bash "$ASSET_DIR/verify1.sh"
