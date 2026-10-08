#!/usr/bin/env bash
set -Eeuo pipefail
assets="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
minor=${1:?};version=${2:?}
for node in node01 controlplane; do
 if [[ "$node" == node01 ]]; then timeout 360 ssh -o BatchMode=yes -o ConnectTimeout=5 node01 bash -s -- packages "$minor" "$version" < "$assets/node-packages.sh"
 else timeout --foreground 360 bash "$assets/node-packages.sh" packages "$minor" "$version"; fi
done
# The supported two-VM teaching image exposes one CPU per VM.
# Exempt only this sizing check in the disposable lab; retain all other checks.
init_args=()
if (( $(nproc) < 2 )); then init_args+=(--ignore-preflight-errors=NumCPU); fi
kubeadm init "${init_args[@]}" --kubernetes-version "v$version" --apiserver-advertise-address 172.30.1.2 --control-plane-endpoint controlplane:6443 --pod-network-cidr 10.244.0.0/16 --cri-socket unix:///run/containerd/containerd.sock
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf
if ! command -v helm >/dev/null; then
 arch=$(uname -m); case "$arch" in x86_64) arch=amd64;; aarch64|arm64) arch=arm64;; esac
 archive="helm-v3.19.0-linux-$arch.tar.gz"
 curl -fLsS --max-time 120 "https://get.helm.sh/$archive" -o "/tmp/$archive"
 expected=$(curl -fLsS --max-time 30 "https://get.helm.sh/$archive.sha256sum" | awk '{print $1}')
 printf '%s  %s\n' "$expected" "/tmp/$archive" | sha256sum -c -
 tar -xzf "/tmp/$archive" -C /tmp
 install -m 0755 "/tmp/linux-$arch/helm" /usr/local/bin/helm
fi
helm repo add cilium https://helm.cilium.io/ --force-update
helm repo update
helm install cilium cilium/cilium --version 1.20.2 --namespace kube-system \
 --set cleanState=true --set operator.replicas=1 --set kubeProxyReplacement=false --set routingMode=tunnel --set tunnelProtocol=vxlan \
 --set ipam.mode=cluster-pool --set 'ipam.operator.clusterPoolIPv4PodCIDRList[0]=10.244.0.0/16'
join=$(kubeadm token create --print-join-command)
timeout 180 ssh -o BatchMode=yes -o ConnectTimeout=5 node01 "$join --cri-socket unix:///run/containerd/containerd.sock"
# Keep the control-plane scheduling taint: only CNI/core system Pods tolerate it.
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
kubectl -n kube-system rollout status deployment/cilium-operator --timeout=300s
kubectl wait --for=condition=Ready node --all --timeout=300s
# Reset cleanup is needed once; future agent restarts should preserve BPF state.
helm upgrade cilium cilium/cilium --version 1.20.2 --namespace kube-system --reuse-values --set cleanState=false
