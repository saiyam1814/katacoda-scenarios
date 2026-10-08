#!/usr/bin/env bash
LAB_ID=infra-01-kubeadm-bootstrap
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
k get nodes -o json | json_check 'set(x["metadata"]["name"] for x in d["items"])==set(["controlplane","node01"]) and all(x["status"]["nodeInfo"]["kubeletVersion"]=="v1.35.9" and any(c["type"]=="Ready" and c["status"]=="True" for c in x["status"]["conditions"]) for x in d["items"])' 'Both nodes must be Ready on v1.35.9'
k get node controlplane -o json | json_check 'any(t["key"]=="node-role.kubernetes.io/control-plane" and t["effect"]=="NoSchedule" for t in d["spec"].get("taints",[]))' 'Retain the control-plane scheduling taint'
for node in controlplane node01; do
 k -n cka01 get pod "dns-$node" -o json | json_check "d['spec'].get('nodeName')=='$node' and d['spec'].get('nodeSelector',{}).get('kubernetes.io/hostname')=='$node'" 'DNS probe is on the wrong node'
 k -n cka01 exec "dns-$node" -- nslookup kubernetes.default.svc.cluster.local >/dev/null || fail "DNS failed from $node"
done
pass 'Real kubeadm cluster, worker join, taint and DNS from both hosts verified'
