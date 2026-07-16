#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

PROM_OPERATOR_VERSION=v0.92.1

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# --- Prometheus Operator (CRDs are big: server-side apply) ------------------------
curl -sL "https://github.com/prometheus-operator/prometheus-operator/releases/download/${PROM_OPERATOR_VERSION}/bundle.yaml" -o /tmp/bundle.yaml
kubectl apply --server-side -f /tmp/bundle.yaml --force-conflicts
kubectl -n default rollout status deploy/prometheus-operator --timeout=600s || true

# --- A Prometheus instance that selects rules labelled release=prometheus ---------
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  namespace: monitoring
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus
rules:
  - apiGroups: [""]
    resources: ["nodes", "services", "endpoints", "pods"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get"]
  - apiGroups: ["networking.k8s.io"]
    resources: ["ingresses"]
    verbs: ["get", "list", "watch"]
  - nonResourceURLs: ["/metrics"]
    verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus
subjects:
  - kind: ServiceAccount
    name: prometheus
    namespace: monitoring
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
---
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: main
  namespace: monitoring
spec:
  replicas: 1
  serviceAccountName: prometheus
  serviceMonitorSelector:
    matchLabels:
      team: frontend
  ruleSelector:
    matchLabels:
      release: prometheus
  resources:
    requests:
      memory: 200Mi
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus-main
  namespace: monitoring
spec:
  selector:
    prometheus: main
  ports:
    - port: 9090
      targetPort: 9090
EOF

# --- The frontend app whose errors we alert on -------------------------------------
# Tiny stdlib-only web app exposing http_requests_total{status=...} on /metrics.
kubectl create namespace frontend --dry-run=client -o yaml | kubectl apply -f -
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-src
  namespace: frontend
data:
  app.py: |
    import http.server

    counts = {"200": 0, "500": 0}

    class H(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path == "/metrics":
                body = "# HELP http_requests_total Total HTTP requests\n"
                body += "# TYPE http_requests_total counter\n"
                for s, c in counts.items():
                    body += 'http_requests_total{status="%s",service="frontend"} %d\n' % (s, c)
                data = body.encode()
                self.send_response(200)
                self.send_header("Content-Type", "text/plain; version=0.0.4")
                self.end_headers()
                self.wfile.write(data)
            elif self.path == "/boom":
                counts["500"] += 1
                self.send_response(500)
                self.end_headers()
                self.wfile.write(b"boom\n")
            else:
                counts["200"] += 1
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b"ok\n")

        def log_message(self, *a):
            pass

    http.server.ThreadingHTTPServer(("", 8080), H).serve_forever()
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: frontend
  labels:
    app: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: app
          image: python:3.12-alpine
          command: ["python", "/src/app.py"]
          ports:
            - name: http
              containerPort: 8080
          volumeMounts:
            - name: src
              mountPath: /src
      volumes:
        - name: src
          configMap:
            name: frontend-src
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: frontend
  labels:
    app: frontend
spec:
  selector:
    app: frontend
  ports:
    - name: http
      port: 8080
      targetPort: 8080
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: frontend
  namespace: monitoring
  labels:
    team: frontend
spec:
  namespaceSelector:
    matchNames: ["frontend"]
  selector:
    matchLabels:
      app: frontend
  endpoints:
    - port: http
      interval: 10s
---
# Steady traffic: ~8% of requests hit /boom (HTTP 500) - above the 5% SLO
apiVersion: v1
kind: Pod
metadata:
  name: load
  namespace: frontend
spec:
  containers:
    - name: curl
      image: curlimages/curl:8.9.1
      command: ["/bin/sh", "-c"]
      args:
        - |
          while true; do
            for i in 1 2 3 4 5 6 7 8 9 10 11; do
              curl -s http://frontend.frontend.svc:8080/ >/dev/null
            done
            curl -s http://frontend.frontend.svc:8080/boom >/dev/null
            sleep 0.3
          done
EOF

kubectl -n frontend rollout status deploy/frontend --timeout=300s || true
# the operator needs a moment to create the StatefulSet pod before we can wait on it
for i in $(seq 1 60); do
  kubectl -n monitoring get pod prometheus-main-0 >/dev/null 2>&1 && break
  sleep 5
done
kubectl -n monitoring wait --for=condition=ready pod/prometheus-main-0 --timeout=300s || true

touch /tmp/.cnpe-setup-done
