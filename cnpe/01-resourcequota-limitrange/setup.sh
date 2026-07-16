#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config

# Wait for the API server to be reachable
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

# The squad already runs a workload in the namespace.
kubectl create namespace squad-nebula --dry-run=client -o yaml | kubectl apply -f -

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nebula-api
  namespace: squad-nebula
  labels:
    team: squad-nebula
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nebula-api
  template:
    metadata:
      labels:
        app: nebula-api
    spec:
      containers:
        - name: api
          image: nginx:1.27
          ports:
            - containerPort: 80
EOF

kubectl -n squad-nebula rollout status deploy/nebula-api --timeout=180s || true

touch /tmp/.cnpe-setup-done
