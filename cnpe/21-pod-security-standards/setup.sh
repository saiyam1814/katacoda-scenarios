#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

for ns in fleet-1 fleet-2 fleet-3 fleet-4; do
  kubectl create namespace "$ns" --dry-run=client -o yaml | kubectl apply -f -
done

# fleet-1: clean workload
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ledger
  namespace: fleet-1
spec:
  replicas: 1
  selector: { matchLabels: { app: ledger } }
  template:
    metadata: { labels: { app: ledger } }
    spec:
      containers:
        - name: app
          image: nginx:1.27-alpine
EOF

# fleet-2: violates baseline (hostPath volume)
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: log-scraper
  namespace: fleet-2
spec:
  replicas: 1
  selector: { matchLabels: { app: log-scraper } }
  template:
    metadata: { labels: { app: log-scraper } }
    spec:
      containers:
        - name: app
          image: busybox:1.36
          command: ["sh", "-c", "sleep infinity"]
          volumeMounts:
            - name: varlog
              mountPath: /host-logs
      volumes:
        - name: varlog
          hostPath:
            path: /var/log
EOF

# fleet-3: clean workload
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: quote-api
  namespace: fleet-3
spec:
  replicas: 1
  selector: { matchLabels: { app: quote-api } }
  template:
    metadata: { labels: { app: quote-api } }
    spec:
      containers:
        - name: app
          image: nginx:1.27-alpine
EOF

# fleet-4: violates baseline (hostNetwork + privileged)
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: net-probe
  namespace: fleet-4
spec:
  replicas: 1
  selector: { matchLabels: { app: net-probe } }
  template:
    metadata: { labels: { app: net-probe } }
    spec:
      hostNetwork: true
      containers:
        - name: app
          image: busybox:1.36
          command: ["sh", "-c", "sleep infinity"]
          securityContext:
            privileged: true
EOF

for ns in fleet-1 fleet-2 fleet-3 fleet-4; do
  kubectl -n "$ns" rollout status deploy --timeout=180s || true
done

touch /tmp/.cnpe-setup-done
