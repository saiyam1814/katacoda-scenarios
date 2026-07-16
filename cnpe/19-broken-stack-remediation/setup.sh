#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

kubectl create namespace metrics-portal --dry-run=client -o yaml | kubectl apply -f -

# 1) A quota that is far too tight (applied BEFORE the workloads)
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: portal-quota
  namespace: metrics-portal
spec:
  hard:
    pods: "1"
EOF

# 2) metrics-db requires a Secret that nobody created (CreateContainerConfigError)
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: metrics-db
  namespace: metrics-portal
  labels:
    app: metrics-db
spec:
  replicas: 1
  selector:
    matchLabels:
      app: metrics-db
  template:
    metadata:
      labels:
        app: metrics-db
    spec:
      containers:
        - name: postgres
          image: postgres:16-alpine
          env:
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: metrics-db-auth
                  key: POSTGRES_PASSWORD
          ports:
            - containerPort: 5432
EOF

# give the db pod a head start so it consumes the quota slot
sleep 8

# 3) metrics-ui mounts a PVC that does not exist (Pending once quota allows)
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: metrics-ui
  namespace: metrics-portal
  labels:
    app: metrics-ui
spec:
  replicas: 1
  selector:
    matchLabels:
      app: metrics-ui
  template:
    metadata:
      labels:
        app: metrics-ui
    spec:
      containers:
        - name: grafana
          image: grafana/grafana:12.3.0
          ports:
            - containerPort: 3000
          volumeMounts:
            - name: data
              mountPath: /var/lib/grafana
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: metrics-ui-data
EOF

touch /tmp/.cnpe-setup-done
