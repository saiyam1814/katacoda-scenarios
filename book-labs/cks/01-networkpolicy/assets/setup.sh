#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-01-networkpolicy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin

bash "$(dirname "$0")/base-setup.sh"
for namespace in book-cks-egress book-cks-metadata; do
 reset_ns "$namespace"
 kubectl -n "$namespace" create deployment web --image=nginx:1.28.0-alpine
 kubectl -n "$namespace" expose deployment web --port=80
 kubectl -n "$namespace" run client --labels=app=client --image=busybox:1.37.0 --command -- sleep 3600
 ready_deploy "$namespace" web
 ready_pod "$namespace" client
done
# A real HTTP service in its own Linux network namespace, outside Pod and node namespaces.
# This is synthetic training metadata, never a real cloud credential endpoint.
command -v ip >/dev/null
test -d /etc/kubernetes/manifests || fail 'Metadata route setup requires host access on the disposable node'
if ip netns list | grep -q '^book-metadata '; then ip netns pids book-metadata | xargs -r kill; ip netns del book-metadata; fi
ip link del book-meta-host 2>/dev/null || true
ip netns add book-metadata
ip link add book-meta-host type veth peer name book-meta-peer
ip link set book-meta-peer netns book-metadata
ip addr add 169.254.88.1/30 dev book-meta-host
ip link set book-meta-host up
ip netns exec book-metadata ip addr add 169.254.88.2/30 dev book-meta-peer
ip netns exec book-metadata ip link set book-meta-peer up
ip netns exec book-metadata ip link set lo up
ip netns exec book-metadata ip addr add 169.254.169.254/32 dev lo
ip netns exec book-metadata ip route add default via 169.254.88.1
ip route replace 169.254.169.254/32 via 169.254.88.2 dev book-meta-host
sysctl -w net.ipv4.ip_forward=1
iptables -C FORWARD -o book-meta-host -j ACCEPT 2>/dev/null || iptables -I FORWARD -o book-meta-host -j ACCEPT
iptables -C FORWARD -i book-meta-host -j ACCEPT 2>/dev/null || iptables -I FORWARD -i book-meta-host -j ACCEPT
mkdir -p "$STATE_DIR/metadata-root"
printf 'synthetic-metadata-no-credentials\n' > "$STATE_DIR/metadata-root/index.html"
nohup ip netns exec book-metadata python3 -m http.server 80 --bind 169.254.169.254 --directory "$STATE_DIR/metadata-root" >"$STATE_DIR/metadata-http.log" 2>&1 </dev/null &
for attempt in $(seq 1 30); do if kubectl -n book-cks-metadata exec client -- wget -T 2 -qO- http://169.254.169.254/ | grep -q synthetic-metadata; then break; fi; sleep 1; done
kubectl -n book-cks-metadata exec client -- wget -T 2 -qO- http://169.254.169.254/ | grep -q synthetic-metadata
kubectl -n book-cks-metadata exec client -- wget -T 2 -qO- http://web/ >/dev/null

setup_done
