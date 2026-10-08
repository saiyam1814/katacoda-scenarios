#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-06-rollout-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
reset_ns book-cka-rollout
kubectl -n book-cka-rollout create deployment web --image=nginx:1.27.5 --replicas=2
kubectl -n book-cka-rollout annotate deployment web kubernetes.io/change-cause='Working release'
ready_deploy book-cka-rollout web
kubectl -n book-cka-rollout patch deployment web --type=strategic -p '{"metadata":{"annotations":{"kubernetes.io/change-cause":"Broken release"}},"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:book-missing-release"}]}}}}'
kubectl -n book-cka-rollout create deployment update-demo --image=nginx:1.27.5 --replicas=4
ready_deploy book-cka-rollout update-demo
setup_done
