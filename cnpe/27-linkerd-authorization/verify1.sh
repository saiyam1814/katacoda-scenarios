#!/bin/bash
S=$(kubectl -n payments get server.policy.linkerd.io checkout -o json 2>/dev/null) || exit 1

python3 - "$S" <<'PYEOF' || exit 1
import json, sys
s = json.loads(sys.argv[1])
spec = s["spec"]
assert spec["podSelector"]["matchLabels"]["app"] == "checkout"
assert str(spec["port"]) == "8080"
assert spec.get("proxyProtocol") == "HTTP/1"
PYEOF
exit 0
