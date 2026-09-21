# Exception exported! 🎉

You ran the full distributed-tracing loop: enable OTLP export with env vars, batch
spans into Jaeger, filter by `error=true`, and read the `exception` event off the span.

## Key facts to remember

- **4317 = OTLP/gRPC, 4318 = OTLP/HTTP** - match the exporter protocol to the collector configuration
- `kubectl set env deploy/<name> KEY=value` edits + restarts in one move
- OTel SDKs batch spans - allow time for export, then check collector and application logs if no traces appear
- Exceptions live as span **events** named `exception` with attributes
  `exception.message`, `exception.type`, `exception.stacktrace`
- In Jaeger search, `error=true` finds spans whose status is ERROR
- Exact-match files (`exception.json`) are graded byte-by-byte - copy, don't retype

📖 This lab is **Chapter 18** of the *CNPE Scenarios and Solutions* book.

Next lab: **19 - Unblock metrics-portal without editing Deployments**.
