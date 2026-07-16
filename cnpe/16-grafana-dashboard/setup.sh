#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

kubectl create namespace obs --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# --- Prometheus (svc name: prom, ns: obs) -------------------------------------
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: prom-config
  namespace: obs
data:
  prometheus.yml: |
    global:
      scrape_interval: 10s
    scrape_configs:
      - job_name: prometheus
        static_configs:
          - targets: ["localhost:9090"]
      - job_name: web-shop
        static_configs:
          - targets: ["web-shop.obs.svc:8080"]
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prom
  namespace: obs
  labels:
    app: prom
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prom
  template:
    metadata:
      labels:
        app: prom
    spec:
      containers:
        - name: prometheus
          image: prom/prometheus:v3.5.0
          args:
            - --config.file=/etc/prometheus/prometheus.yml
            - --storage.tsdb.path=/prometheus
          ports:
            - containerPort: 9090
          volumeMounts:
            - name: config
              mountPath: /etc/prometheus
      volumes:
        - name: config
          configMap:
            name: prom-config
---
apiVersion: v1
kind: Service
metadata:
  name: prom
  namespace: obs
spec:
  selector:
    app: prom
  ports:
    - port: 9090
      targetPort: 9090
---
# An app that exposes http_requests_total, plus a traffic generator
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-shop-src
  namespace: obs
data:
  app.py: |
    import http.server

    counts = {"/": 0, "/checkout": 0, "/err": 0}

    class H(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path == "/metrics":
                body = "# HELP http_requests_total Total HTTP requests\n"
                body += "# TYPE http_requests_total counter\n"
                for path, c in counts.items():
                    code = "500" if path == "/err" else "200"
                    body += 'http_requests_total{code="%s",handler="%s",service="web-shop"} %d\n' % (code, path, c)
                data = body.encode()
                self.send_response(200)
                self.send_header("Content-Type", "text/plain; version=0.0.4")
                self.end_headers()
                self.wfile.write(data)
                return
            if self.path in counts:
                counts[self.path] += 1
                self.send_response(500 if self.path == "/err" else 200)
                self.end_headers()
                self.wfile.write(b"ok\n")
                return
            self.send_response(404)
            self.end_headers()

        def log_message(self, *a):
            pass

    http.server.ThreadingHTTPServer(("", 8080), H).serve_forever()
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-shop
  namespace: obs
  labels:
    app: web-shop
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-shop
  template:
    metadata:
      labels:
        app: web-shop
    spec:
      containers:
        - name: app
          image: python:3.12-alpine
          command: ["python", "/src/app.py"]
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: src
              mountPath: /src
      volumes:
        - name: src
          configMap:
            name: web-shop-src
---
apiVersion: v1
kind: Service
metadata:
  name: web-shop
  namespace: obs
spec:
  selector:
    app: web-shop
  ports:
    - port: 8080
      targetPort: 8080
---
apiVersion: v1
kind: Pod
metadata:
  name: shopper
  namespace: obs
spec:
  containers:
    - name: curl
      image: curlimages/curl:8.9.1
      command: ["/bin/sh", "-c"]
      args:
        - while true; do curl -s http://web-shop.obs.svc:8080/ >/dev/null; curl -s http://web-shop.obs.svc:8080/checkout >/dev/null; curl -s http://web-shop.obs.svc:8080/err >/dev/null; sleep 1; done
EOF

# --- Grafana (ns: monitoring) ---------------------------------------------------
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
  labels:
    app: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
        - name: grafana
          image: grafana/grafana:12.3.0
          ports:
            - containerPort: 3000
          env:
            - name: GF_SECURITY_ADMIN_PASSWORD
              value: admin
            - name: GF_AUTH_ANONYMOUS_ENABLED
              value: "true"
            - name: GF_AUTH_ANONYMOUS_ORG_ROLE
              value: Admin
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: monitoring
spec:
  selector:
    app: grafana
  ports:
    - port: 80
      targetPort: 3000
EOF

kubectl -n obs rollout status deploy/prom --timeout=300s || true
kubectl -n obs rollout status deploy/web-shop --timeout=300s || true
kubectl -n monitoring rollout status deploy/grafana --timeout=300s || true

touch /tmp/.cnpe-setup-done
