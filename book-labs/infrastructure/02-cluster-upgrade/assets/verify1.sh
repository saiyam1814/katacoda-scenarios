#!/usr/bin/env bash
LAB_ID=infra-02-cluster-upgrade
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
k version -o json | json_check 'd["serverVersion"]["gitVersion"]=="v1.35.9"' 'API server is not upgraded to v1.35.9'
k get node controlplane -o json | json_check 'd["status"]["nodeInfo"]["kubeletVersion"]=="v1.35.9" and not d["spec"].get("unschedulable",False) and any(c["type"]=="Ready" and c["status"]=="True" for c in d["status"]["conditions"])' 'Control-plane kubelet must be upgraded, Ready and uncordoned'
k get node node01 -o json | json_check 'd["status"]["nodeInfo"]["kubeletVersion"]=="v1.34.12" and any(c["type"]=="Ready" and c["status"]=="True" for c in d["status"]["conditions"])' 'This step checks control-plane-first ordering; worker should still be v1.34.12'
k get --raw=/readyz >/dev/null
bash "$ASSET_DIR/check-application.sh"
pass 'Control plane upgraded by one minor while the worker remains on the previous minor'
