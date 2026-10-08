#!/usr/bin/env bash
set -Eeuo pipefail
action=${1:?}; minor=${2:-1.35}; version=${3:-1.35.9}
case "$action" in
reset)
 test -f /etc/killercoda/host || test "${BOOK_LAB_ALLOW_DISPOSABLE_HOST:-0}" = 1 || { printf 'Requires a disposable Killercoda host.\n' >&2; exit 1; }
 kubeadm reset -f
 # The reset has stopped old Pods. Remove only cluster network configuration/state.
 rm -f /etc/cni/net.d/*.conf /etc/cni/net.d/*.conflist
 rm -rf /var/lib/cni
 ;;
packages)
 swapoff -a
 install -d -m 0755 /etc/apt/keyrings
 curl -fLsS --max-time 30 "https://pkgs.k8s.io/core:/stable:/v$minor/deb/Release.key" | gpg --dearmor --yes -o /etc/apt/keyrings/book-kubernetes.gpg
 printf 'deb [signed-by=/etc/apt/keyrings/book-kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v%s/deb/ /\n' "$minor" > /etc/apt/sources.list.d/kubernetes.list
 apt-get update -qq
 pkg=$(apt-cache madison kubeadm | awk -v wanted="$version-" '!found && index($3,wanted)==1{print $3;found=1}')
 test -n "$pkg" || { printf 'Requested package %s is unavailable.\n' "$version" >&2; exit 1; }
 apt-mark unhold kubeadm kubelet kubectl || true
 DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-downgrades kubeadm="$pkg" kubelet="$pkg" kubectl="$pkg"
 apt-mark hold kubeadm kubelet kubectl
 systemctl daemon-reload
 systemctl enable kubelet
 printf '%s\n' "$pkg" > /var/tmp/book-kubernetes-package
 ;;
upgrade-kubeadm)
 install -d -m 0755 /etc/apt/keyrings
 curl -fLsS --max-time 30 "https://pkgs.k8s.io/core:/stable:/v$minor/deb/Release.key" | gpg --dearmor --yes -o /etc/apt/keyrings/book-kubernetes.gpg
 printf 'deb [signed-by=/etc/apt/keyrings/book-kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v%s/deb/ /\n' "$minor" > /etc/apt/sources.list.d/kubernetes.list
 apt-get update -qq
 pkg=$(apt-cache madison kubeadm | awk -v wanted="$version-" '!found && index($3,wanted)==1{print $3;found=1}')
 test -n "$pkg"
 apt-mark unhold kubeadm
 DEBIAN_FRONTEND=noninteractive apt-get install -y kubeadm="$pkg"
 apt-mark hold kubeadm
 printf '%s\n' "$pkg" > /var/tmp/book-kubernetes-package
 ;;
upgrade-kubelet)
 pkg=$(cat /var/tmp/book-kubernetes-package)
 apt-mark unhold kubelet kubectl
 DEBIAN_FRONTEND=noninteractive apt-get install -y kubelet="$pkg" kubectl="$pkg"
 apt-mark hold kubelet kubectl
 systemctl daemon-reload
 systemctl restart kubelet
 ;;
*) printf 'Unknown node action\n' >&2; exit 1;;
esac
