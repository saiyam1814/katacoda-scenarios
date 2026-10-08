#!/usr/bin/env bash
LAB_ID=infra-04-worker-operations
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

setup_begin
api_wait
remote true
k wait --for=condition=Ready node/node01 --timeout=180s
ns cka20
ns cka23
k taint node controlplane node-role.kubernetes.io/control-plane:NoSchedule- 2>/dev/null || true
cat <<'EOF' | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: resident, namespace: cka23}
spec:
  replicas: 1
  selector: {matchLabels: {app: resident}}
  template:
    metadata: {labels: {app: resident}}
    spec:
      # Keep this fixture on the stopped worker even if a learner pauses.
      # Explicit kubectl drain still evicts it in the maintenance task.
      tolerations:
      - {key: node.kubernetes.io/not-ready, operator: Exists, effect: NoExecute}
      - {key: node.kubernetes.io/unreachable, operator: Exists, effect: NoExecute}
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - {key: kubernetes.io/hostname, operator: In, values: [node01]}
      containers:
      - name: web
        image: nginx:1.28.0-alpine
        resources:
          requests: {cpu: 10m, memory: 16Mi}
EOF
kubectl -n cka23 rollout status deployment/resident --timeout=180s
k -n cka23 get pods -l app=resident -o json > "$STATE_DIR/resident-before.json"
cat "$STATE_DIR/resident-before.json" | json_check 'len(d["items"]) == 1 and d["items"][0]["spec"]["nodeName"] == "node01"' 'Resident Pod did not start on node01'
remote systemctl stop kubelet
for n in $(seq 1 75); do
 condition=$(k get node node01 -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
 if [[ "$condition" != True ]]; then break; fi
 sleep 2
done
[[ "$condition" != True ]] || fail 'The node did not show the injected heartbeat loss'
setup_done
