#!/usr/bin/env bash
# Kubernetes 1.37 single-node playground with a curated set of 1.37 alpha
# feature gates switched on.
set -euo pipefail

ARCH="amd64"
DOWNLOAD_DIR="/usr/local/bin"
UNIT_DIR="/usr/lib/systemd/system"
REL_TEMPL_VER="v0.21.1"        # kubelet unit templates from kubernetes/release
CNI_PLUGINS_VERSION="v1.9.1"   # base CNI binaries used by Flannel
ALPHA_DIR="/root/alpha"

# Gates handed to kube-apiserver / kube-controller-manager / kube-scheduler.
# NOTE: 1.37 enforces feature gate dependencies. CompositePodGroup requires both
# GenericWorkload and TopologyAwareWorkloadScheduling, or kube-apiserver refuses to
# start with "depends on features that are disabled". H2CContainerProbe requires
# NodeDeclaredFeatures, which is GA (on) in 1.37.
CP_GATES="GenericWorkload=true,TopologyAwareWorkloadScheduling=true,CompositePodGroup=true,PodGroupPreemptionPolicy=true,VolumeBindMountOptions=true,EmptyDirVolumeMode=true,StatefulSetRecreateStrategy=true,AtomicWriteVolumeUserFields=true,H2CContainerProbe=true"
# Alpha/beta API groups the above need served.
RUNTIME_CONFIG="scheduling.k8s.io/v1beta1=true,scheduling.k8s.io/v1alpha3=true"

need() { command -v "$1" >/dev/null 2>&1 || { echo "missing: $1"; exit 1; }; }

echo "==> [0/10] Preflight"
need curl; need tar
[ "$(id -u)" -eq 0 ] || { echo "Run as root"; exit 1; }
export DEBIAN_FRONTEND=noninteractive

echo "==> [1/10] Base packages"
apt-get update -y
apt-get install -y ca-certificates apt-transport-https curl gpg python3

echo "==> [2/10] containerd with systemd cgroups"
apt-get install -y containerd
mkdir -p /etc/containerd
containerd config default >/etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl daemon-reload
systemctl enable --now containerd

echo "==> [3/10] Kernel modules, sysctls, swap"
modprobe overlay || true
modprobe br_netfilter || true
cat >/etc/modules-load.d/containerd.conf <<'EOF'
overlay
br_netfilter
EOF
cat >/etc/sysctl.d/kubernetes.conf <<'EOF'
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null
sed -i '/[[:space:]]swap[[:space:]]/ s/^/#/' /etc/fstab || true
swapoff -a || true

echo "==> [4/10] CNI plugins ${CNI_PLUGINS_VERSION}"
mkdir -p /opt/cni/bin
curl -fsSL --retry 3 "https://github.com/containernetworking/plugins/releases/download/${CNI_PLUGINS_VERSION}/cni-plugins-linux-${ARCH}-${CNI_PLUGINS_VERSION}.tgz" \
  | tar -C /opt/cni/bin -xz

echo "==> [5/10] Resolve latest Kubernetes 1.37.x"
REL="$(curl -fsSL https://dl.k8s.io/release/stable-1.37.txt || true)"
if [ -z "${REL}" ]; then
  S="$(curl -fsSL https://dl.k8s.io/release/stable.txt || true)"
  case "${S:-}" in v1.37.*) REL="$S" ;; esac
fi
[ -n "${REL:-}" ] || REL="v1.37.0"
echo "     -> Using ${REL}"

echo "==> [6/10] Download kubeadm, kubelet, kubectl (${REL})"
mkdir -p "${DOWNLOAD_DIR}"; chmod 755 "${DOWNLOAD_DIR}"
fetch_bin() {
  local bin="$1"
  curl -fsSL --retry 3 --retry-connrefused -o "${DOWNLOAD_DIR}/${bin}" \
    "https://dl.k8s.io/release/${REL}/bin/linux/${ARCH}/${bin}" \
  || curl -fsSL --retry 3 --retry-connrefused -o "${DOWNLOAD_DIR}/${bin}" \
    "https://dl.k8s.io/${REL}/bin/linux/${ARCH}/${bin}"
  chmod +x "${DOWNLOAD_DIR}/${bin}"
}
for b in kubeadm kubelet kubectl; do echo "   - ${b}"; fetch_bin "${b}"; done

echo "==> [7/10] kubelet systemd units"
curl -fsSL "https://raw.githubusercontent.com/kubernetes/release/${REL_TEMPL_VER}/cmd/krel/templates/latest/kubelet/kubelet.service" \
  | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" > "${UNIT_DIR}/kubelet.service"
mkdir -p "${UNIT_DIR}/kubelet.service.d"
curl -fsSL "https://raw.githubusercontent.com/kubernetes/release/${REL_TEMPL_VER}/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf" \
  | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" > "${UNIT_DIR}/kubelet.service.d/10-kubeadm.conf"
systemctl daemon-reload
systemctl enable --now kubelet || true

echo "==> [8/10] Write kubeadm config (with 1.37 alpha gates)"
mkdir -p "${ALPHA_DIR}"
HOST="$(hostname -s)"
cat >"${ALPHA_DIR}/kubeadm-alpha.yaml" <<EOF
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
nodeRegistration:
  criSocket: unix:///run/containerd/containerd.sock
  ignorePreflightErrors:
  - all
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
kubernetesVersion: ${REL}
controlPlaneEndpoint: "${HOST}"
networking:
  podSubnet: 10.244.0.0/16
apiServer:
  extraArgs:
  - name: feature-gates
    value: "${CP_GATES}"
  - name: runtime-config
    value: "${RUNTIME_CONFIG}"
controllerManager:
  extraArgs:
  - name: feature-gates
    value: "${CP_GATES}"
scheduler:
  extraArgs:
  - name: feature-gates
    value: "${CP_GATES}"
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
featureGates:
  VolumeBindMountOptions: true
  EmptyDirVolumeMode: true
  AtomicWriteVolumeUserFields: true
  H2CContainerProbe: true
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: iptables
EOF

# Same config minus every gate - the safety net if a gate ever gets renamed upstream.
cat >"${ALPHA_DIR}/kubeadm-plain.yaml" <<EOF
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
nodeRegistration:
  criSocket: unix:///run/containerd/containerd.sock
  ignorePreflightErrors:
  - all
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
kubernetesVersion: ${REL}
controlPlaneEndpoint: "${HOST}"
networking:
  podSubnet: 10.244.0.0/16
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: iptables
EOF

echo "==> [9/10] Pull control-plane images"
kubeadm config images pull --config "${ALPHA_DIR}/kubeadm-alpha.yaml" >/dev/null 2>&1 \
  || kubeadm config images pull --cri-socket unix:///run/containerd/containerd.sock --kubernetes-version "${REL}"

echo "==> [10/10] kubeadm init"
ALPHA_ON=1
if ! kubeadm init --config "${ALPHA_DIR}/kubeadm-alpha.yaml" --upload-certs --ignore-preflight-errors=all; then
  echo "!!! init with alpha gates failed - falling back to a plain 1.37 cluster"
  kubeadm reset -f --cri-socket unix:///run/containerd/containerd.sock >/dev/null 2>&1 || true
  rm -rf /etc/kubernetes /var/lib/etcd
  kubeadm init --config "${ALPHA_DIR}/kubeadm-plain.yaml" --upload-certs --ignore-preflight-errors=all
  ALPHA_ON=0
fi
echo "${ALPHA_ON}" > "${ALPHA_DIR}/.alpha-enabled"

mkdir -p /root/.kube
cp -f /etc/kubernetes/admin.conf /root/.kube/config
export KUBECONFIG=/root/.kube/config
grep -q 'KUBECONFIG' /root/.bashrc || echo 'export KUBECONFIG=/root/.kube/config' >> /root/.bashrc

echo "==> Flannel CNI"
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

echo "==> Untaint the control plane (single node)"
kubectl taint nodes "${HOST}" node-role.kubernetes.io/control-plane:NoSchedule- 2>/dev/null || true

# ---------------------------------------------------------------------------
# Helper: add / remove feature gates on a running cluster, and roll back.
# ---------------------------------------------------------------------------
cat >"${ALPHA_DIR}/gate.sh" <<'GATE'
#!/usr/bin/env bash
# gate.sh add     <Gate>=<true|false> [more,gates=true] -> add gates to the control plane
# gate.sh kubelet <Gate>=true[,Gate2=true]              -> add gates to the kubelet, then restart it
# gate.sh api     <group/version=true>                  -> add a runtime-config entry to kube-apiserver
# gate.sh show                                          -> print the gates currently in the manifests
# gate.sh backup                                        -> snapshot the static pod manifests
# gate.sh restore                                       -> put the snapshot back
set -euo pipefail
M=/etc/kubernetes/manifests
B=/root/alpha/manifest-backup
COMPONENTS="kube-apiserver kube-controller-manager kube-scheduler"

merge_arg() { # file  flagname  additions
  python3 - "$1" "$2" "$3" <<'PY'
import sys, re
path, flag, add = sys.argv[1], sys.argv[2], sys.argv[3]
lines = open(path).read().split('\n')
out, found = [], False
for ln in lines:
    m = re.match(r'^(\s*)- --%s=(.*)$' % re.escape(flag), ln)
    if m:
        found = True
        cur = dict(kv.split('=', 1) for kv in m.group(2).split(',') if '=' in kv)
        cur.update(dict(kv.split('=', 1) for kv in add.split(',') if '=' in kv))
        ln = '%s- --%s=%s' % (m.group(1), flag, ','.join('%s=%s' % kv for kv in cur.items()))
    out.append(ln)
if not found:
    for i, ln in enumerate(out):
        if re.match(r'^\s*- --', ln):
            indent = re.match(r'^(\s*)', ln).group(1)
            out.insert(i, '%s- --%s=%s' % (indent, flag, add))
            break
open(path, 'w').write('\n'.join(out))
PY
}

wait_api() {
  echo "   waiting for the API server to restart..."
  sleep 8   # let the kubelet tear the old static pod down first
  for _ in $(seq 1 90); do
    if kubectl get --raw /readyz >/dev/null 2>&1; then
      echo "   API server is back"; return 0
    fi
    sleep 2
  done
  echo "   API server did not come back - check 'crictl ps -a' and run '$0 restore'"
  return 1
}

case "${1:-}" in
  backup)
    mkdir -p "$B"; cp -f "$M"/*.yaml "$B"/; echo "manifests backed up to $B" ;;
  restore)
    [ -d "$B" ] || { echo "no backup - run '$0 backup' first"; exit 1; }
    cp -f "$B"/*.yaml "$M"/; wait_api ;;
  show)
    for c in $COMPONENTS; do
      echo "--- $c"
      grep -E -- '--(feature-gates|runtime-config)=' "$M/$c.yaml" || echo "    (none)"
    done ;;
  add)
    [ -n "${2:-}" ] || { echo "usage: $0 add Gate=true[,Gate2=false]"; exit 1; }
    mkdir -p "$B"; [ -f "$B/kube-apiserver.yaml" ] || cp -f "$M"/*.yaml "$B"/
    for c in $COMPONENTS; do merge_arg "$M/$c.yaml" feature-gates "$2"; done
    echo "added '$2' to: $COMPONENTS"; wait_api ;;
  kubelet)
    [ -n "${2:-}" ] || { echo "usage: $0 kubelet Gate=true[,Gate2=true]"; exit 1; }
    K=/var/lib/kubelet/config.yaml
    cp -f "$K" "$K.bak"
    python3 - "$K" "$2" <<'PY'
import sys, re
path, add = sys.argv[1], sys.argv[2]
want = dict(kv.split('=', 1) for kv in add.split(',') if '=' in kv)
lines = open(path).read().rstrip('\n').split('\n')
out, i, found = [], 0, False
while i < len(lines):
    ln = lines[i]
    if re.match(r'^featureGates:\s*$', ln):
        found = True
        out.append('featureGates:')
        i += 1
        cur = {}
        while i < len(lines) and re.match(r'^\s+\S', lines[i]):
            m = re.match(r'^\s+([A-Za-z0-9_]+):\s*(\S+)\s*$', lines[i])
            if m:
                cur[m.group(1)] = m.group(2)
            i += 1
        cur.update(want)
        out.extend('  %s: %s' % kv for kv in sorted(cur.items()))
        continue
    out.append(ln)
    i += 1
if not found:
    out.append('featureGates:')
    out.extend('  %s: %s' % kv for kv in sorted(want.items()))
open(path, 'w').write('\n'.join(out) + '\n')
PY
    systemctl restart kubelet
    echo "added '$2' to the kubelet (backup: $K.bak); waiting for the node..."
    for _ in $(seq 1 45); do
      kubectl get node "$(hostname -s)" >/dev/null 2>&1 && { echo "   node is back"; break; }
      sleep 2
    done ;;
  api)
    [ -n "${2:-}" ] || { echo "usage: $0 api group/version=true"; exit 1; }
    mkdir -p "$B"; [ -f "$B/kube-apiserver.yaml" ] || cp -f "$M"/*.yaml "$B"/
    merge_arg "$M/kube-apiserver.yaml" runtime-config "$2"
    echo "added '$2' to kube-apiserver --runtime-config"; wait_api ;;
  *)
    sed -n '2,7p' "$0" ;;
esac
GATE
chmod +x "${ALPHA_DIR}/gate.sh"

echo
if [ "${ALPHA_ON}" = "1" ]; then
  echo "Kubernetes ${REL} is up with these alpha/beta gates on:"
  echo "  ${CP_GATES}"
else
  echo "Kubernetes ${REL} is up (plain - alpha gates were NOT applied)."
  echo "Turn them on with: /root/alpha/gate.sh add ${CP_GATES}"
fi
echo "Helper: /root/alpha/gate.sh   (add | kubelet | api | show | backup | restore)"
