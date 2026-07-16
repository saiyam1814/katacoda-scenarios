#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

# Two storage classes backed by the local-path provisioner.
# fast-iops plays the role of the "high-IOPS" class, standard the general one.
cat <<'EOF' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-iops
  annotations:
    storage.acme.dev/tier: "high-iops"
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
  annotations:
    storage.acme.dev/tier: "general"
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
EOF

kubectl create namespace storage-lab --dry-run=client -o yaml | kubectl apply -f -

# Workloads that reference claims which do not exist yet.
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pg
  namespace: storage-lab
  labels:
    app: pg
spec:
  replicas: 1
  selector:
    matchLabels:
      app: pg
  template:
    metadata:
      labels:
        app: pg
    spec:
      containers:
        - name: postgres
          image: postgres:16-alpine
          env:
            - name: POSTGRES_PASSWORD
              value: "labs3cret"
            - name: PGDATA
              value: /var/lib/postgresql/data/pgdata
          ports:
            - containerPort: 5432
          volumeMounts:
            - name: data
              mountPath: /var/lib/postgresql/data
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: pg-storage
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cdn
  namespace: storage-lab
  labels:
    app: cdn
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cdn
  template:
    metadata:
      labels:
        app: cdn
    spec:
      containers:
        - name: nginx
          image: nginx:1.27-alpine
          ports:
            - containerPort: 80
          volumeMounts:
            - name: cache
              mountPath: /usr/share/nginx/html
      volumes:
        - name: cache
          persistentVolumeClaim:
            claimName: cdn-cache
EOF

touch /tmp/.cnpe-setup-done
