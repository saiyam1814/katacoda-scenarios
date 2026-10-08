#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-08-host-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin

test -d /etc/kubernetes/manifests || fail 'Use the disposable kubeadm VM backend'
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq apparmor apparmor-utils jq python3-yaml python3-tomlkit curl gnupg ca-certificates bzip2
[[ $(cat /sys/module/apparmor/parameters/enabled) == Y ]] || fail 'AppArmor must be enabled in the host kernel'
test -r /sys/kernel/btf/vmlinux || fail 'Falco modern eBPF requires kernel BTF'
mkdir -p "$STATE_DIR/downloads" /opt/book-tools/kube-bench
cd "$STATE_DIR/downloads"
curl -fL --retry 3 -O https://github.com/aquasecurity/kube-bench/releases/download/v0.16.0/kube-bench_0.16.0_linux_amd64.tar.gz
curl -fL --retry 3 -O https://github.com/aquasecurity/kube-bench/releases/download/v0.16.0/kube-bench_0.16.0_checksums.txt
grep ' kube-bench_0.16.0_linux_amd64.tar.gz$' kube-bench_0.16.0_checksums.txt | sha256sum -c -
tar -xzf kube-bench_0.16.0_linux_amd64.tar.gz -C /opt/book-tools/kube-bench
install /opt/book-tools/kube-bench/kube-bench /usr/local/bin/kube-bench
# Current kube-bench upstream maps through Kubernetes 1.34. Explicitly use the
# supplied CIS 1.12 profile for these two still-applicable controls, not a claim
# of certification coverage for an unlisted server minor.
cp /etc/kubernetes/manifests/kube-controller-manager.yaml "$STATE_DIR/controller-original.yaml"
python3 - <<'PYSET'
import yaml,pathlib,os
p=pathlib.Path('/etc/kubernetes/manifests/kube-controller-manager.yaml');d=yaml.safe_load(p.read_text());c=d['spec']['containers'][0]['command'];c[:]=[x for x in c if not x.startswith('--profiling=')]+['--profiling=true'];t=pathlib.Path('/etc/kubernetes/book-controller.tmp');t.write_text(yaml.safe_dump(d));os.replace(t,p)
PYSET
chmod 644 /etc/kubernetes/manifests/kube-controller-manager.yaml
for n in $(seq 1 90); do pgrep -af '^kube-controller-manager.*--profiling=true' >/dev/null && break; sleep 1; done
pgrep -af '^kube-controller-manager.*--profiling=true'
kube-bench run --benchmark cis-1.12 --config-dir /opt/book-tools/kube-bench/cfg --config /opt/book-tools/kube-bench/cfg/config.yaml --check 1.1.3,1.3.2 --json > "$WORK_DIR/cis-before.json"
# Install the complete pinned gVisor release, including its required sidecars.
curl -fL --retry 3 -O https://github.com/google/gvisor/releases/download/release-20260928.0/gvisor-x86_64.tar.bz2
curl -fL --retry 3 -O https://github.com/google/gvisor/releases/download/release-20260928.0/SHA256SUMS
grep 'gvisor-x86_64.tar.bz2$' SHA256SUMS | sha256sum -c -
tar -xjf gvisor-x86_64.tar.bz2 -C /usr/local/bin
runsc --version
cp /etc/containerd/config.toml "$STATE_DIR/containerd-original.toml"
python3 - <<'PYSET'
import pathlib,tomlkit
p=pathlib.Path('/etc/containerd/config.toml');d=tomlkit.parse(p.read_text());plugins=d.setdefault('plugins',{});key='io.containerd.cri.v1.runtime' if d.get('version',2)==3 else 'io.containerd.grpc.v1.cri';r=plugins.setdefault(key,{}).setdefault('containerd',{}).setdefault('runtimes',{});r['runsc']={'runtime_type':'io.containerd.runsc.v1'};p.write_text(tomlkit.dumps(d))
PYSET
systemctl restart containerd
for n in $(seq 1 90); do kubectl get --raw=/readyz >/dev/null 2>&1 && break; sleep 1; done
kubectl get --raw=/readyz
# Official pinned Falco Debian package. Preserve its supplied metadata plugins.
curl -fsSL https://falco.org/repo/falcosecurity-packages.asc | gpg --dearmor --yes -o /usr/share/keyrings/falco-archive-keyring.gpg
printf '%s\n' 'deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main' > /etc/apt/sources.list.d/book-falco.list
apt-get update -qq
falco_version=$(apt-cache madison falco | awk '$3 ~ /^0[.]45[.]0/ {print $3;exit}')
test -n "$falco_version" || fail 'Pinned Falco 0.45.0 package unavailable'
FALCO_FRONTEND=noninteractive FALCO_DRIVER_CHOICE=none FALCOCTL_ENABLED=no apt-get install -y -qq "falco=$falco_version"
falco --version
mkdir -p /etc/falco/rules.d /var/log/falco
cat > /etc/systemd/system/book-falco.service <<'UNIT'
[Unit]
Description=CKS book Falco modern eBPF
After=containerd.service
[Service]
ExecStart=/usr/bin/falco -c /etc/falco/falco.yaml -o engine.kind=modern_ebpf
Restart=on-failure
[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl start book-falco
sleep 3
systemctl is-active book-falco
reset_ns book-cks-host
kubectl -n book-cks-host run shell-target --image=busybox:1.37.0 --command -- sleep 3600
ready_pod book-cks-host shell-target
# An actual unwanted systemd service, bound to a harmless high port.
mkdir -p /var/lib/book-debug
printf 'temporary debug service\n' > /var/lib/book-debug/index.html
cat > /etc/systemd/system/book-debug.service <<'UNIT'
[Unit]
Description=Temporary book debug HTTP service
[Service]
ExecStart=/usr/bin/python3 -m http.server 9999 --bind 0.0.0.0 --directory /var/lib/book-debug
[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now book-debug
curl --retry 10 --retry-connrefused --retry-delay 1 -fsS http://127.0.0.1:9999/
ss -lntp '( sport = :9999 )' > "$STATE_DIR/debug-listener-before.txt"

setup_done
