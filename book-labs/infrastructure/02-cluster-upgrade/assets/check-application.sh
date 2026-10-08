#!/usr/bin/env bash
LAB_ID=infra-02-cluster-upgrade
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"
[[ "$(k -n upgrade-check get deployment web -o jsonpath='{.metadata.uid}')" == "$(cat "$STATE_DIR/application-uid")" ]] || fail 'Preserve the original application Deployment'
k -n upgrade-check get deployment web -o json | json_check 'd["spec"]["replicas"]==2 and d["status"].get("availableReplicas",0)>=1' 'At least one of the two original application replicas must be available'
k -n upgrade-check get pdb web -o json | json_check 'd["spec"].get("minAvailable")==1' 'Preserve the application disruption budget'
pod=$(k -n upgrade-check get pods -l app=web -o json | python3 -c 'import json,sys;p=[p for p in json.load(sys.stdin)["items"] if not p["metadata"].get("deletionTimestamp") and any(c["type"]=="Ready" and c["status"]=="True" for c in p.get("status",{}).get("conditions",[]))];sys.exit("No Ready application Pod") if not p else print(p[0]["metadata"]["name"])')
k -n upgrade-check exec "$pod" -- wget -qO- http://127.0.0.1/ >/dev/null || fail 'Application HTTP check failed'
