#!/usr/bin/env bash
LAB_ID=infra-04-worker-operations
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
k -n cka20 delete pod probe --ignore-not-found --grace-period=1 --wait=true --timeout=60s
k -n cka23 delete pod blocked --ignore-not-found --grace-period=1 --wait=true --timeout=60s
kubectl drain node01 --ignore-daemonsets --timeout=180s
kubectl -n cka23 rollout status deployment/resident --timeout=180s
k uncordon node01
k -n cka23 run restored --image=busybox:1.37.0 --restart=Never --overrides='{"spec":{"nodeSelector":{"kubernetes.io/hostname":"node01"}}}' --command -- sh -c 'echo kubelet-ok; sleep 3600'
ready_pod cka23 restored
