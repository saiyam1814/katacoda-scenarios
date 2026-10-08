#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-02-pod-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin

bash "$(dirname "$0")/base-setup.sh"
reset_ns book-cks-privileged
kubectl -n book-cks-privileged create deployment inspector --image=busybox:1.37.0 -- sh -c 'sleep 3600'
kubectl -n book-cks-privileged patch deploy inspector --type=merge -p '{"spec":{"template":{"spec":{"containers":[{"name":"busybox","image":"busybox:1.37.0","command":["sh","-c","sleep 3600"],"securityContext":{"privileged":true,"runAsUser":0}}]}}}}'
ready_deploy book-cks-privileged inspector

setup_done
