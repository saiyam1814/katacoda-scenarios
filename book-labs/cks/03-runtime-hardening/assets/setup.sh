#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-03-runtime-hardening
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin

bash "$(dirname "$0")/base-setup.sh"
reset_ns book-cks-readonly
reset_ns book-cks-seccomp
mkdir -p /var/lib/kubelet/seccomp/profiles
# The profile belongs on the actual single Kubernetes node, not in a ConfigMap.
test -d /etc/kubernetes/manifests || fail 'This group requires a disposable kubeadm VM with host access'

setup_done
