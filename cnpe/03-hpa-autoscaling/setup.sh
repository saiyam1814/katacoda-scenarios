#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

METRICS_SERVER_VERSION=v0.8.0

# Install metrics-server (required for CPU-based HPA) if not present
if ! kubectl get deploy metrics-server -n kube-system >/dev/null 2>&1; then
  curl -sL "https://github.com/kubernetes-sigs/metrics-server/releases/download/${METRICS_SERVER_VERSION}/components.yaml" -o /tmp/metrics-server.yaml
  kubectl apply -f /tmp/metrics-server.yaml
  # kubelets in lab clusters use self-signed certs
  kubectl -n kube-system patch deploy metrics-server --type=json \
    -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi

kubectl create namespace edge-web --dry-run=client -o yaml | kubectl apply -f -

# The frontend: burns CPU on every request so the HPA has something to react to.
# CPU requests are set - the HPA percentage math needs them.
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: storefront-src
  namespace: edge-web
data:
  app.py: |
    import http.server

    class H(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            # simulate rendering work (~CPU burst per request)
            total = sum(i * i for i in range(300000))
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK %d\n" % (total % 97))

        def log_message(self, *a):
            pass

    http.server.ThreadingHTTPServer(("", 80), H).serve_forever()
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: storefront
  namespace: edge-web
  labels:
    app: storefront
spec:
  replicas: 2
  selector:
    matchLabels:
      app: storefront
  template:
    metadata:
      labels:
        app: storefront
    spec:
      containers:
        - name: web
          image: python:3.12-alpine
          command: ["python", "/src/app.py"]
          ports:
            - containerPort: 80
          volumeMounts:
            - name: src
              mountPath: /src
          resources:
            requests:
              cpu: 100m
            limits:
              cpu: 300m
      volumes:
        - name: src
          configMap:
            name: storefront-src
---
apiVersion: v1
kind: Service
metadata:
  name: storefront
  namespace: edge-web
spec:
  selector:
    app: storefront
  ports:
    - port: 80
      targetPort: 80
EOF

kubectl -n edge-web rollout status deploy/storefront --timeout=300s || true
kubectl -n kube-system rollout status deploy/metrics-server --timeout=300s || true

touch /tmp/.cnpe-setup-done
