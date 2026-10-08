#!/usr/bin/env bash
LAB_ID=infra-02-cluster-upgrade
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
k get nodes -o json | json_check 'len(d["items"])==2 and all(x["status"]["nodeInfo"]["kubeletVersion"]=="v1.35.9" and not x["spec"].get("unschedulable",False) and any(c["type"]=="Ready" and c["status"]=="True" for c in x["status"]["conditions"]) for x in d["items"])' 'Both upgraded nodes must be Ready and schedulable'
k get --raw=/readyz >/dev/null
bash "$ASSET_DIR/check-application.sh"
k get nodes -o custom-columns=NAME:.metadata.name,VERSION:.status.nodeInfo.kubeletVersion > "$STATE_DIR/actual-versions.txt"
cmp -s /tmp/cka10-versions.txt "$STATE_DIR/actual-versions.txt" || fail 'Saved version evidence does not match the live cluster'
pass 'Both nodes upgraded, actual application HTTP works and saved version evidence matches'
