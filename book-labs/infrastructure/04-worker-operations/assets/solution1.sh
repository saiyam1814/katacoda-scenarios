#!/usr/bin/env bash
LAB_ID=infra-04-worker-operations
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
remote systemctl start kubelet
kubectl wait --for=condition=Ready node/node01 --timeout=180s
printf '%s\n' 'Cause: kubelet service was stopped on node01.' 'Recovery: started kubelet and verified fresh Pod execution.' > /tmp/cka20-root-cause.txt
k -n cka20 run probe --image=busybox:1.37.0 --restart=Never --overrides='{"spec":{"nodeSelector":{"kubernetes.io/hostname":"node01"}}}' --command -- sleep 3600
ready_pod cka20 probe
