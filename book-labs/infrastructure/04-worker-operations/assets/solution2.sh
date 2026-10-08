#!/usr/bin/env bash
LAB_ID=infra-04-worker-operations
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
k cordon node01
k -n cka23 run blocked --image=nginx:1.28.0-alpine --restart=Never --overrides='{"spec":{"nodeSelector":{"kubernetes.io/hostname":"node01"}}}'
uid=$(k -n cka23 get pod blocked -o jsonpath='{.metadata.uid}')
for n in $(seq 1 30); do
 if k -n cka23 get events --field-selector "involvedObject.uid=$uid,reason=FailedScheduling" -o json | python3 -c 'import json,sys;sys.exit(not bool(json.load(sys.stdin)["items"]))'; then break; fi
 sleep 1
done
