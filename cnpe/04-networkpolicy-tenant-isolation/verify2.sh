#!/bin/bash
NP=$(kubectl -n tenant-red get networkpolicy allow-api-from-edge -o json 2>/dev/null) || exit 1

python3 - "$NP" <<'PYEOF' || exit 1
import json, sys
np = json.loads(sys.argv[1])
spec = np["spec"]

# selects app=api
assert spec.get("podSelector", {}).get("matchLabels", {}).get("app") == "api"

# ingress rule: from purpose=edge namespaces on TCP 8080
ing = spec.get("ingress", [])
ok = False
for rule in ing:
    froms = rule.get("from", [])
    ports = rule.get("ports", [])
    ns_ok = any(f.get("namespaceSelector", {}).get("matchLabels", {}).get("purpose") == "edge" for f in froms)
    port_ok = any(str(p.get("port")) == "8080" and p.get("protocol", "TCP") == "TCP" for p in ports)
    if ns_ok and port_ok:
        ok = True
assert ok

# egress: UDP 53 allowed somewhere
eg = spec.get("egress", [])
dns_ok = False
for rule in eg:
    for p in rule.get("ports", []):
        if str(p.get("port")) == "53" and p.get("protocol") == "UDP":
            dns_ok = True
assert dns_ok
assert "Egress" in spec.get("policyTypes", [])
PYEOF

# If an enforcing CNI is running, also test real connectivity
if kubectl -n kube-system get pods 2>/dev/null | grep -qE "cilium|calico"; then
  kubectl -n ingress-gw exec edge-client -- curl -s --max-time 5 http://api.tenant-red.svc:8080/hostname >/dev/null 2>&1 || exit 1
  kubectl -n other-squad exec squad-client -- curl -s --max-time 4 http://api.tenant-red.svc:8080/hostname >/dev/null 2>&1 && exit 1
fi

exit 0
