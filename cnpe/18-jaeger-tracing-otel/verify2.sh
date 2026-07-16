#!/bin/bash
# The exported file must match the trace's exception exactly
python3 <<'PYEOF' || exit 1
import json
import os
p = "/root/exception.json" if os.path.exists("/root/exception.json") else os.path.expanduser("~/exception.json")
d = json.load(open(p))
assert d.get("key") == "exception.message"
assert d.get("type") == "string"
assert d.get("value") == "connection refused to payment-svc:8080"
PYEOF

# Jaeger must actually know the service (proves tracing flowed end-to-end)
kubectl -n observability port-forward svc/jaeger-query 16699:16686 >/dev/null 2>&1 &
PF=$!
sleep 3
SVCS=$(curl -s http://localhost:16699/api/services 2>/dev/null)
kill $PF 2>/dev/null
echo "$SVCS" | grep -q "span-switch" || exit 1

exit 0
