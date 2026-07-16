#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

kubectl create namespace observability --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace trace-lab --dry-run=client -o yaml | kubectl apply -f -

# --- Jaeger all-in-one with OTLP ingest ------------------------------------------
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jaeger
  namespace: observability
  labels:
    app: jaeger
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jaeger
  template:
    metadata:
      labels:
        app: jaeger
    spec:
      containers:
        - name: jaeger
          image: jaegertracing/all-in-one:1.62.0
          env:
            - name: COLLECTOR_OTLP_ENABLED
              value: "true"
          ports:
            - containerPort: 16686
            - containerPort: 4317
            - containerPort: 4318
---
apiVersion: v1
kind: Service
metadata:
  name: jaeger-collector
  namespace: observability
spec:
  selector:
    app: jaeger
  ports:
    - name: otlp-grpc
      port: 4317
      targetPort: 4317
    - name: otlp-http
      port: 4318
      targetPort: 4318
---
apiVersion: v1
kind: Service
metadata:
  name: jaeger-query
  namespace: observability
spec:
  selector:
    app: jaeger
  ports:
    - name: ui
      port: 16686
      targetPort: 16686
EOF

# --- span-switch: an app with tracing built in but switched OFF --------------------
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: span-switch-src
  namespace: trace-lab
data:
  main.py: |
    import os, random, time

    enabled = os.getenv("TRACING_ENABLED") == "1"
    endpoint = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT")

    tracer = None
    if enabled and endpoint:
        from opentelemetry import trace
        from opentelemetry.sdk.resources import Resource
        from opentelemetry.sdk.trace import TracerProvider
        from opentelemetry.sdk.trace.export import BatchSpanProcessor
        from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter

        provider = TracerProvider(
            resource=Resource.create({"service.name": "span-switch"}))
        provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter()))
        trace.set_tracer_provider(provider)
        tracer = trace.get_tracer("span-switch")
        print("tracing ENABLED, exporting OTLP to %s" % endpoint, flush=True)
    else:
        print("tracing DISABLED "
              "(need TRACING_ENABLED=1 and OTEL_EXPORTER_OTLP_ENDPOINT)", flush=True)

    def charge_card(order):
        from opentelemetry.trace import StatusCode
        with tracer.start_as_current_span("charge-card") as span:
            span.set_attribute("order.id", order)
            time.sleep(random.uniform(0.01, 0.05))
            if order % 5 == 0:
                err = RuntimeError("connection refused to payment-svc:8080")
                span.record_exception(err)
                span.set_status(StatusCode.ERROR, str(err))

    def checkout(order):
        if tracer is None:
            time.sleep(0.05)
            return
        with tracer.start_as_current_span("checkout") as span:
            span.set_attribute("order.id", order)
            charge_card(order)

    order = 0
    while True:
        order += 1
        checkout(order)
        time.sleep(1)
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: span-switch
  namespace: trace-lab
  labels:
    app: span-switch
spec:
  replicas: 1
  selector:
    matchLabels:
      app: span-switch
  template:
    metadata:
      labels:
        app: span-switch
    spec:
      containers:
        - name: app
          image: python:3.12-slim
          command: ["/bin/sh", "-c"]
          args:
            - pip install --quiet --no-cache-dir
              opentelemetry-sdk==1.27.0
              opentelemetry-exporter-otlp-proto-http==1.27.0
              && python /app/main.py
          env:
            - name: TRACING_ENABLED
              value: "0"
          volumeMounts:
            - name: src
              mountPath: /app
      volumes:
        - name: src
          configMap:
            name: span-switch-src
EOF

kubectl -n observability rollout status deploy/jaeger --timeout=300s || true
kubectl -n trace-lab rollout status deploy/span-switch --timeout=600s || true

touch /tmp/.cnpe-setup-done
