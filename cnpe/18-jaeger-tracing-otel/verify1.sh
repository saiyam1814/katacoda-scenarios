#!/bin/bash
ENVS=$(kubectl -n trace-lab get deploy span-switch -o json 2>/dev/null | \
  python3 -c "
import json, sys
d = json.load(sys.stdin)
envs = {e['name']: e.get('value','') for e in d['spec']['template']['spec']['containers'][0].get('env', [])}
print(envs.get('TRACING_ENABLED',''), envs.get('OTEL_EXPORTER_OTLP_ENDPOINT',''))
")
set -- $ENVS
[ "$1" = "1" ] || exit 1
echo "$2" | grep -q "^http://jaeger-collector.observability.svc:4318" || exit 1

kubectl -n trace-lab wait --for=condition=available deploy/span-switch --timeout=10s >/dev/null 2>&1 || exit 1
exit 0
