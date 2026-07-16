# Find the error span and export the exception

Expose the Jaeger UI:

```bash
kubectl -n observability port-forward --address 0.0.0.0 svc/jaeger-query 16686:16686 >/dev/null 2>&1 &
sleep 2
echo "Jaeger UI is up"
```{{exec}}

Open [Jaeger on port 16686]({{TRAFFIC_HOST1_16686}}):

1. **Service:** `span-switch` (give it ~30–60s to appear — spans ship in batches)
2. **Tags:** `error=true`
3. **Find Traces** → open a red trace → expand the failed **`charge-card`** span
4. Under **Logs / Events** you'll find an `exception` event —
   copy the value of **`exception.message`**

Then write the file (replace the value only if yours differs):

```bash
cat > /root/exception.json <<'EOF'
{"key": "exception.message", "type": "string", "value": "connection refused to payment-svc:8080"}
EOF
cat /root/exception.json
```{{exec}}

<details><summary>✦ No service in Jaeger?</summary>

- Wait 30–60s: the BatchSpanProcessor flushes on an interval
- `kubectl -n trace-lab logs deploy/span-switch --tail=5` — is tracing ENABLED?
- `kubectl -n observability logs deploy/jaeger --tail=10` — collector complaints?
- Only every 5th order errors, so error traces appear within ~5 seconds of each other

</details>

<details><summary>✦ Hunting via API instead of UI</summary>

```bash
curl -s "http://localhost:16686/api/traces?service=span-switch&tags=%7B%22error%22%3A%22true%22%7D&limit=5" \
  | python3 -c "
import json, sys
d = json.load(sys.stdin)
for t in d.get('data', []):
    for s in t['spans']:
        for lg in s.get('logs', []):
            fields = {f['key']: f['value'] for f in lg['fields']}
            if 'exception.message' in fields:
                print(fields['exception.message'])
" | sort -u
```{{exec}}

</details>
