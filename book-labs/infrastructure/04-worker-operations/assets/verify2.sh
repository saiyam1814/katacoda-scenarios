#!/usr/bin/env bash
LAB_ID=infra-04-worker-operations
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
k get node node01 -o json | json_check 'd["spec"].get("unschedulable") == True' 'Worker must be cordoned'
k -n cka23 get pod blocked -o json | json_check 'not d["spec"].get("nodeName") and d["spec"].get("nodeSelector",{}).get("kubernetes.io/hostname")=="node01" and d["status"]["phase"]=="Pending"' 'The blocked Pod must be unscheduled and constrained with a selector'
uid=$(k -n cka23 get pod blocked -o jsonpath='{.metadata.uid}')
k -n cka23 get events --field-selector "involvedObject.uid=$uid,reason=FailedScheduling" -o json | json_check 'any("unschedulable" in x.get("message","") for x in d["items"])' 'Missing current Pod scheduling evidence for the cordoned node'
k -n cka23 get pods -l app=resident -o json | json_check 'any(not p["metadata"].get("deletionTimestamp") and p["status"].get("phase")=="Running" and p["spec"].get("nodeName")=="node01" and any(c["type"]=="Ready" and c["status"]=="True" for c in p.get("status",{}).get("conditions",[])) for p in d["items"])' 'Cordon should leave the existing resident Pod running'
pass 'Cordon blocks a new scheduled Pod while the existing workload remains running'
