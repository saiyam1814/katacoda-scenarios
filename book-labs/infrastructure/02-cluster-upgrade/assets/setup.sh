#!/usr/bin/env bash
LAB_ID=infra-02-cluster-upgrade
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

setup_begin

remote true
# These are the two disposable VMs in this scenario, never an external context.
timeout 120 ssh -o BatchMode=yes -o ConnectTimeout=5 node01 bash -s -- reset < "$ASSET_DIR/node-packages.sh"
timeout 120 bash "$ASSET_DIR/node-packages.sh" reset

bash "$ASSET_DIR/build-cluster.sh" 1.34 1.34.12
ns upgrade-check
cat <<'EOF' | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: web, namespace: upgrade-check}
spec:
  replicas: 2
  selector: {matchLabels: {app: web}}
  template:
    metadata: {labels: {app: web}}
    spec:
      tolerations:
      - {key: node-role.kubernetes.io/control-plane, operator: Exists, effect: NoSchedule}
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector: {matchLabels: {app: web}}
              topologyKey: kubernetes.io/hostname
      containers:
      - name: nginx
        image: nginx:1.28.0-alpine
        readinessProbe:
          httpGet: {path: /, port: 80}
          periodSeconds: 2
          initialDelaySeconds: 1
        resources:
          requests: {cpu: 10m, memory: 16Mi}
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata: {name: web, namespace: upgrade-check}
spec:
  minAvailable: 1
  selector: {matchLabels: {app: web}}
EOF
kubectl -n upgrade-check rollout status deployment/web --timeout=180s
# etcd's data volume is host-mounted. Save, copy out, then remove only this snapshot file.
id=$(etcd_id)
crictl exec "$id" etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key snapshot save /var/lib/etcd/book-upgrade.db
mkdir -p /var/backups
cp /var/lib/etcd/book-upgrade.db /var/backups/before-upgrade.db
rm /var/lib/etcd/book-upgrade.db
k -n upgrade-check get deployment web -o jsonpath='{.metadata.uid}' > "$STATE_DIR/application-uid"
setup_done
