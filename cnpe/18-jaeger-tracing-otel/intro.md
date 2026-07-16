# Enable span-switch Tracing and Export the Exception

**Domain:** Observability and Operations &nbsp;|&nbsp; **Suggested time:** 12 minutes

Support says checkouts fail "sometimes". The app **`span-switch`** (namespace
`trace-lab`) ships with OpenTelemetry, but tracing is **switched off**. A Jaeger
collector is reachable in-cluster at
`http://jaeger-collector.observability.svc:4318` (OTLP/HTTP).

**Your task:**

1. On Deployment `span-switch`, set:
   - **`TRACING_ENABLED=1`**
   - **`OTEL_EXPORTER_OTLP_ENDPOINT=http://jaeger-collector.observability.svc:4318`**
2. In **Jaeger**, find an **error span** for service `span-switch`
3. Copy the exception message from the span and write it to **`/root/exception.json`**
   in exactly this shape:

```json
{"key": "exception.message", "type": "string", "value": "<message from the trace>"}
```

Click **START** when ready.
