#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-10-incident-investigation
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin

test -d /etc/kubernetes/manifests || fail 'Use the disposable kubeadm VM backend'
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq python3-yaml
mkdir -p /etc/kubernetes/book-incident-audit /var/log/book-incident-audit
cat > /etc/kubernetes/book-incident-audit/policy.yaml <<'YAML'
apiVersion: audit.k8s.io/v1
kind: Policy
omitStages: [RequestReceived]
rules:
- level: Metadata
YAML
cat > "$STATE_DIR/audit-spec.json" <<'JSON'
{"flags":{"audit-policy-file":"/etc/kubernetes/book-incident-audit/policy.yaml","audit-log-path":"/var/log/book-incident-audit/audit.jsonl","audit-log-maxage":"1","audit-log-maxbackup":"2","audit-log-maxsize":"20","audit-log-batch-max-wait":"1s"},"mounts":[{"name":"book-incident-audit-policy","path":"/etc/kubernetes/book-incident-audit"},{"name":"book-incident-audit-log","path":"/var/log/book-incident-audit","readOnly":false,"type":"DirectoryOrCreate"}]}
JSON
old=$(crictl ps --name kube-apiserver -q | head -1)
python3 "$(dirname "$0")/controlplane.py" patch "$STATE_DIR/audit-spec.json"
python3 "$(dirname "$0")/controlplane.py" replacement "$old" 180
reset_ns book-cks-incident
reset_ns book-cks-incident-control
for n in $(seq 1 30); do kubectl -n book-cks-incident-control get sa default >/dev/null 2>&1 && break; sleep 1; done
for n in $(seq 1 30); do kubectl -n book-cks-incident get serviceaccount default >/dev/null 2>&1 && break; sleep 1; done
kubectl -n book-cks-incident get serviceaccount default >/dev/null
kubectl -n book-cks-incident create serviceaccount actor
kubectl -n book-cks-incident create secret generic payments --from-literal=api-key=training-only-never-real-credentials
kubectl -n book-cks-incident create role incident-access --verb=get,list,delete --resource=secrets,pods
kubectl -n book-cks-incident create rolebinding incident-access --role=incident-access --serviceaccount=book-cks-incident:actor
kubectl -n book-cks-incident run actor --labels=app=actor --image=curlimages/curl:8.12.1 --overrides='{"spec":{"serviceAccountName":"actor"}}' --command -- sleep 3600
kubectl -n book-cks-incident-control run observer --labels=app=observer --image=curlimages/curl:8.12.1 --command -- sleep 3600
kubectl -n book-cks-incident run victim --image=busybox:1.37.0 --command -- sleep 3600
kubectl -n book-cks-incident-control create deployment control-web --image=nginx:1.28.0-alpine
kubectl -n book-cks-incident-control expose deployment control-web --port=80
for pod in actor victim; do ready_pod book-cks-incident "$pod"; done
ready_pod book-cks-incident-control observer
ready_deploy book-cks-incident-control control-web
web_ip=$(kubectl -n book-cks-incident-control get svc control-web -o jsonpath='{.spec.clusterIP}')
printf '%s' "$web_ip" > "$STATE_DIR/control-web-ip"
kubectl -n book-cks-incident exec actor -- curl -fsS --max-time 3 "http://$web_ip/" >/dev/null
# Test actual egress enforcement before generating the investigation evidence.
kubectl apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: setup-canary, namespace: book-cks-incident}
spec: {podSelector: {matchLabels: {app: actor}}, policyTypes: [Egress], egress: []}
YAML
enforced=no
for n in $(seq 1 20); do
 if ! kubectl -n book-cks-incident exec actor -- curl -fsS --max-time 2 "http://$web_ip/" >/dev/null 2>&1; then enforced=yes;break;fi
 sleep 1
done
kubectl -n book-cks-incident delete netpol setup-canary
test "$enforced" = yes || fail 'CNI must enforce NetworkPolicy'
for n in $(seq 1 30); do kubectl -n book-cks-incident exec actor -- curl -fsS --max-time 2 "http://$web_ip/" >/dev/null 2>&1 && break; sleep 1; done
kubectl -n book-cks-incident exec actor -- curl -fsS --max-time 2 "http://$web_ip/" >/dev/null
# Real requests, using only the Pod's own bound service-account credentials.
for operation in 'GET /api/v1/namespaces/book-cks-incident/secrets/payments 200' 'GET /api/v1/namespaces/kube-system/secrets 403' 'DELETE /api/v1/namespaces/book-cks-incident/pods/victim 200'; do
 read -r method path expected <<< "$operation"
 code=$(kubectl -n book-cks-incident exec actor -- sh -c 'curl -sS --max-time 5 --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -X "$1" -o /dev/null -w "%{http_code}" "https://kubernetes.default.svc$2"' -- "$method" "$path")
 test "$code" = "$expected" || fail "Expected $expected for $method $path; got $code"
done
kubectl -n book-cks-incident get pod actor -o jsonpath='{.status.podIP}' > "$STATE_DIR/actor-ip"
for n in $(seq 1 30); do
 if python3 "$(dirname "$0")/capture-audit.py" "$WORK_DIR/incident.jsonl"; then break;fi
 sleep 1
done
python3 "$(dirname "$0")/capture-audit.py" "$WORK_DIR/incident.jsonl"
sha256sum "$WORK_DIR/incident.jsonl" > "$WORK_DIR/incident-original.sha256"
cp "$WORK_DIR/incident-original.sha256" "$STATE_DIR/incident-original.sha256"

setup_done
