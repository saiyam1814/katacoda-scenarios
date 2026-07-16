#!/bin/bash
AP=$(kubectl -n payments get authorizationpolicy checkout-allow-storefront -o json 2>/dev/null) || exit 1

python3 - "$AP" <<'PYEOF' || exit 1
import json, sys
ap = json.loads(sys.argv[1])
spec = ap["spec"]
assert spec.get("selector", {}).get("matchLabels", {}).get("app") == "checkout"
assert spec.get("action", "ALLOW") == "ALLOW"
principals = []
for rule in spec.get("rules", []):
    for f in rule.get("from", []):
        principals.extend(f.get("source", {}).get("principals", []))
assert "cluster.local/ns/web/sa/storefront" in principals, principals
PYEOF
exit 0
