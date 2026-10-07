#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-06-rollout-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
reset_ns book-cka-rollout
kubectl -n book-cka-rollout create deployment web --image=nginx:1.28.0 --replicas=2
ready_deploy book-cka-rollout web
kubectl -n book-cka-rollout annotate deployment web kubernetes.io/change-cause='Working release'
kubectl -n book-cka-rollout set image deployment/web nginx=nginx:book-image-does-not-exist
kubectl -n book-cka-rollout annotate deployment web kubernetes.io/change-cause='Broken image release' --overwrite
for attempt in $(seq 1 30); do
  revision=$(kubectl -n book-cka-rollout get deploy web -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}')
  [[ "$revision" == 2 ]] && break
  sleep 1
done
[[ "$revision" == 2 ]] || fail 'Broken revision did not reach rollout history' 
setup_done
