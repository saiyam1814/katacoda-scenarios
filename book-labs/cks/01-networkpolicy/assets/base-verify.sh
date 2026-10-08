#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-01-networkpolicy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
# CHECK reports the current state promptly. Setup and solution own long waits.
kubectl --request-timeout=3s get namespace book-cks-green book-cks-blue -o json | json_assert 'len(d["items"]) == 2 and all(n["metadata"]["labels"].get("team") == {"book-cks-green":"green","book-cks-blue":"blue"}[n["metadata"]["name"]] for n in d["items"])' 'Do not change namespace labels'
for pair in 'book-cks-green trusted trusted' 'book-cks-green untrusted untrusted' 'book-cks-blue trusted trusted'; do
  read -r namespace pod access <<< "$pair"
  kubectl --request-timeout=3s -n "$namespace" get pod "$pod" -o json | json_assert "d[\"metadata\"][\"labels\"].get(\"access\") == \"$access\" and not d[\"metadata\"].get(\"deletionTimestamp\") and any(c[\"type\"] == \"Ready\" and c[\"status\"] == \"True\" for c in d.get(\"status\",{}).get(\"conditions\",[]))" "$namespace/$pod must be Ready with its original access label; retry CHECK when ready"
done
for triple in 'book-cks-network local-approved test' 'book-cks-network local-unapproved other' 'book-cks-blue local-approved test'; do
  read -r namespace pod demo <<< "$triple"
  kubectl --request-timeout=3s -n "$namespace" get pod "$pod" -o json | json_assert "d[\"metadata\"][\"labels\"].get(\"demo\") == \"$demo\" and not d[\"metadata\"].get(\"deletionTimestamp\") and any(c[\"type\"] == \"Ready\" and c[\"status\"] == \"True\" for c in d.get(\"status\",{}).get(\"conditions\",[]))" "$namespace/$pod must be Ready with its original demo label"
done
for app in api admin; do
  kubectl --request-timeout=3s -n book-cks-network get deployment "$app" -o json | json_assert 'len(d["spec"]["template"]["spec"]["containers"]) == 1 and d["spec"]["template"]["spec"]["containers"][0]["image"] == "nginx:1.28.0" and not d["spec"]["template"]["spec"]["containers"][0].get("command") and not d["spec"]["template"]["spec"]["containers"][0].get("args") and d["status"].get("observedGeneration",0) >= d["metadata"]["generation"] and d["status"].get("availableReplicas",0) == d["spec"].get("replicas",1) and d["status"].get("updatedReplicas",0) == d["spec"].get("replicas",1) and d["spec"].get("replicas",1) > 0' 'Keep the original server application and wait for its rollout before CHECK'
  service=$(kubectl --request-timeout=3s -n book-cks-network get service "$app" -o json)
  printf '%s' "$service" | json_assert "d[\"spec\"][\"selector\"] == {\"app\":\"$app\"} and len(d[\"spec\"][\"ports\"]) == 1 and d[\"spec\"][\"ports\"][0][\"port\"] == 80 and d[\"spec\"][\"ports\"][0][\"targetPort\"] == 80" 'Preserve the server Service selector and port'
  ip=$(printf '%s' "$service" | python3 -c 'import json,sys; print(json.load(sys.stdin)["spec"]["clusterIP"])')
  if [[ "$app" == api ]]; then api_ip=$ip; else admin_ip=$ip; fi
done
asset_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
python3 "$asset_dir/network_probe.py" "$api_ip" "$admin_ip"
pass "All checks passed for cks-01-networkpolicy"
