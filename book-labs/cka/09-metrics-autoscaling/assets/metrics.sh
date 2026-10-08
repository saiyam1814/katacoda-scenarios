node_exec() { if [[ -n ${BOOK_LAB_NODE_CONTAINER:-} ]]; then docker exec -i "$BOOK_LAB_NODE_CONTAINER" "$@"; else sudo "$@"; fi; }
metrics_prepare() {
 mkdir -p "$WORK_DIR/metrics/base" "$WORK_DIR/metrics/overlay"
 kubectl get nodes -o json > "$WORK_DIR/metrics/nodes.json"
 [[ $(kubectl get nodes --no-headers | wc -l | tr -d ' ') == 1 ]] || fail 'This certificate fixture requires the advertised one-node backend'
 if kubectl -n kube-system get deployment metrics-server >/dev/null 2>&1; then
  [[ $(kubectl -n kube-system get deployment metrics-server -o jsonpath='{.metadata.labels.book-lab}') == "$LAB_ID" ]] || fail 'An existing Metrics Server belongs to another installation; use a fresh VM'
 fi
 curl -fsSL --retry 3 https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.8.1/components.yaml -o "$WORK_DIR/metrics/base/upstream.yaml"
 node_exec cat /var/lib/kubelet/pki/kubelet.crt > "$WORK_DIR/metrics/base/kubelet-ca.pem"
 openssl x509 -in "$WORK_DIR/metrics/base/kubelet-ca.pem" -noout -subject -issuer
 kubectl -n kube-system create configmap book-cka-metrics-tls --from-file=ca.crt="$WORK_DIR/metrics/base/kubelet-ca.pem" --dry-run=client -o json > "$WORK_DIR/metrics/base/ca.json"
 python3 - "$WORK_DIR/metrics" "$LAB_ID" <<'PYMETRICS'
import json,pathlib,sys
p=pathlib.Path(sys.argv[1]);nodes=json.loads((p/'nodes.json').read_text())['items'];n=nodes[0];name=n['metadata']['name'];ip=next(a['address'] for a in n['status']['addresses'] if a['type']=='InternalIP')
patch={'apiVersion':'apps/v1','kind':'Deployment','metadata':{'name':'metrics-server','namespace':'kube-system','labels':{'book-lab':sys.argv[2]}},'spec':{'template':{'spec':{'hostAliases':[{'ip':ip,'hostnames':[name]}],'tolerations':[{'key':'node-role.kubernetes.io/control-plane','operator':'Exists','effect':'NoSchedule'},{'key':'node-role.kubernetes.io/master','operator':'Exists','effect':'NoSchedule'}],'volumes':[{'name':'kubelet-ca','configMap':{'name':'book-cka-metrics-tls'}}],'containers':[{'name':'metrics-server','args':['--cert-dir=/tmp','--secure-port=10250','--kubelet-preferred-address-types=Hostname','--kubelet-use-node-status-port','--metric-resolution=15s','--kubelet-certificate-authority=/kubelet-ca/ca.crt'],'volumeMounts':[{'name':'kubelet-ca','mountPath':'/kubelet-ca','readOnly':True}]}]}}}}
(p/'base/tls-patch.json').write_text(json.dumps(patch))
(p/'base/kustomization.yaml').write_text(json.dumps({'apiVersion':'kustomize.config.k8s.io/v1beta1','kind':'Kustomization','resources':['upstream.yaml','ca.json'],'patches':[{'path':'tls-patch.json'}]}))
PYMETRICS
}
metrics_overlay() {
 cat > "$WORK_DIR/metrics/overlay/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../base
patches:
- target:
    kind: Deployment
    name: metrics-server
  patch: |-
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: metrics-server
    spec:
      template:
        spec:
          containers:
          - name: metrics-server
            resources:
              requests:
                cpu: 200m
YAML
 kubectl kustomize "$WORK_DIR/metrics/overlay" > "$WORK_DIR/metrics/rendered.yaml"
 kubectl apply -k "$WORK_DIR/metrics/overlay"
 kubectl -n kube-system rollout status deployment/metrics-server --timeout=240s
 kubectl wait --for=condition=Available apiservice/v1beta1.metrics.k8s.io --timeout=120s
 for attempt in $(seq 1 45); do kubectl top nodes && return 0; sleep 2; done
 fail 'Metrics API did not supply node samples; inspect Metrics Server logs and the kubelet certificate SAN'
}
metrics_check() {
 kubectl -n kube-system get deployment metrics-server -o json | json_assert 'd["status"].get("availableReplicas",0)>=1 and d["spec"]["template"]["spec"]["containers"][0]["resources"]["requests"]["cpu"]=="200m" and not any(a.startswith("--kubelet-insecure-tls") for a in d["spec"]["template"]["spec"]["containers"][0]["args"]) and any(a.startswith("--kubelet-certificate-authority=") for a in d["spec"]["template"]["spec"]["containers"][0]["args"])' 'Require a Ready Metrics Server with 200m CPU and verified kubelet TLS'
 kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes | json_assert 'len(d["items"])>0 and all(n["usage"]["cpu"] and n["usage"]["memory"] for n in d["items"])' 'Require live node metrics'
}
metrics_cleanup() { if test -f "$WORK_DIR/metrics/overlay/kustomization.yaml"; then kubectl delete -k "$WORK_DIR/metrics/overlay" --ignore-not-found; fi; }
