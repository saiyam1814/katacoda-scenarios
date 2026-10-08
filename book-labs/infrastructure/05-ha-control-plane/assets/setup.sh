#!/usr/bin/env bash
LAB_ID=infra-05-ha-control-plane
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

setup_begin
command -v docker >/dev/null || fail 'Docker is required on the Ubuntu backend'
arch=$(uname -m); case "$arch" in x86_64) arch=amd64;; aarch64|arm64) arch=arm64;; *) fail 'Unsupported CPU architecture';; esac
if ! command -v kind >/dev/null; then
 curl -fLsS --max-time 120 "https://github.com/kubernetes-sigs/kind/releases/download/v0.31.0/kind-linux-$arch" -o "$WORK_DIR/kind"
 curl -fLsS --max-time 30 "https://github.com/kubernetes-sigs/kind/releases/download/v0.31.0/kind-linux-$arch.sha256sum" -o "$WORK_DIR/kind.sha256sum"
 expected=$(awk '{print $1}' "$WORK_DIR/kind.sha256sum"); printf '%s  %s\n' "$expected" "$WORK_DIR/kind" | sha256sum -c -
 install -m 0755 "$WORK_DIR/kind" /usr/local/bin/kind
fi
if ! command -v kubectl >/dev/null; then
 curl -fLsS --max-time 120 "https://dl.k8s.io/release/v1.35.0/bin/linux/$arch/kubectl" -o "$WORK_DIR/kubectl"
 expected=$(curl -fLsS --max-time 30 "https://dl.k8s.io/release/v1.35.0/bin/linux/$arch/kubectl.sha256")
 printf '%s  %s\n' "$expected" "$WORK_DIR/kubectl" | sha256sum -c -
 install -m 0755 "$WORK_DIR/kubectl" /usr/local/bin/kubectl
fi
export KUBECONFIG="$WORK_DIR/kubeconfig"
if docker inspect book-ha-control-plane >/dev/null 2>&1; then fail 'A book-ha cluster already exists. Start a fresh environment for this setup.'; fi
kind create cluster --name book-ha --config "$ASSET_DIR/ha.yaml" --kubeconfig "$KUBECONFIG" --wait 180s
# Reset one member at a time; kubeadm removes its stacked etcd membership first.
for node in book-ha-control-plane3 book-ha-control-plane2; do
 docker exec "$node" kubeadm reset -f
 # The reset API server may still be selected briefly by the load balancer.
 # Deletion is idempotent even if a response is lost after the API accepted it.
 deadline=$((SECONDS + 120))
 until k delete node "$node" --ignore-not-found --wait=false; do
  (( SECONDS < deadline )) || fail "Could not remove reset node $node from the API"
  sleep 2
 done
done
# The external load balancer needs time to stop selecting the reset API servers.
# Wait for the real final state here, rather than failing on a transient EOF.
deadline=$((SECONDS + 180))
until k get nodes -o json | json_check 'len(d["items"])==1 and d["items"][0]["metadata"]["name"]=="book-ha-control-plane" and any(c["type"]=="Ready" and c["status"]=="True" for c in d["items"][0]["status"]["conditions"])' 'Expected one Ready initialized control plane after resetting join targets'; do
  (( SECONDS < deadline )) || fail 'API did not settle after resetting the two join targets'
  sleep 2
done
mkdir -p /root/.kube
cp "$KUBECONFIG" /root/.kube/config
printf 'export KUBECONFIG=%q\n' "$KUBECONFIG" > "$WORK_DIR/environment.sh"
setup_done
