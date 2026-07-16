# Turn tracing on

See the current state — the app tells you what it wants:

```plain
kubectl -n trace-lab logs deploy/span-switch --tail=3
```{{exec}}

Set both environment variables **without editing YAML** (`kubectl set env` is made for
this — and it restarts the Pods for you):

<details><summary>✅ Solution</summary>

```bash
kubectl -n trace-lab set env deploy/span-switch \
  TRACING_ENABLED=1 \
  OTEL_EXPORTER_OTLP_ENDPOINT=http://jaeger-collector.observability.svc:4318
```{{exec}}

</details>

Wait for the new Pod (the container reinstalls its libraries — about a minute):

```bash
kubectl -n trace-lab rollout status deploy/span-switch --timeout=180s
kubectl -n trace-lab logs deploy/span-switch --tail=3
```{{exec}}

You want to see: `tracing ENABLED, exporting OTLP to http://jaeger-collector...`

<details><summary>✦ Why port 4318 and not 4317?</summary>

OTLP has two transports: **4317 = gRPC**, **4318 = HTTP**. The task says OTLP/HTTP,
and the app uses the HTTP exporter — so 4318. Mixing them up is the most common
tracing-lab mistake. The exporter appends `/v1/traces` to the endpoint automatically.

</details>
