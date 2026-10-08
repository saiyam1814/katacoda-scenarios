#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-08-host-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
python3 - <<'PYFIX'
import yaml,pathlib,os
p=pathlib.Path('/etc/kubernetes/manifests/kube-controller-manager.yaml');d=yaml.safe_load(p.read_text());c=d['spec']['containers'][0]['command'];c[:]=[x for x in c if not x.startswith('--profiling=')]+['--profiling=false'];t=pathlib.Path('/etc/kubernetes/book-controller.tmp');t.write_text(yaml.safe_dump(d));t.chmod(0o600);os.replace(t,p)
PYFIX
chmod 600 /var/lib/kubelet/config.yaml
for n in $(seq 1 90); do pgrep -af '^kube-controller-manager.*--profiling=false' >/dev/null && break; sleep 1; done
pgrep -af '^kube-controller-manager.*--profiling=false'
kube-bench run --benchmark cis-1.12 --config-dir /opt/book-tools/kube-bench/cfg --config /opt/book-tools/kube-bench/cfg/config.yaml --check 1.1.3,1.3.2,4.1.9 --json > "$WORK_DIR/cis-after.json"
cat > /etc/apparmor.d/book-deny-tmp <<'PROFILE'
#include <tunables/global>
profile book-deny-tmp flags=(attach_disconnected,mediate_deleted) {
  #include <abstractions/base>
  file,
  network,
  capability,
  signal,
  deny /tmp/** w,
}
PROFILE
apparmor_parser -r /etc/apparmor.d/book-deny-tmp
kubectl -n book-cks-host delete pod apparmor --ignore-not-found
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: apparmor, namespace: book-cks-host}
spec:
  containers:
  - name: apparmor
    image: busybox:1.37.0
    command: [sleep, '3600']
    securityContext:
      appArmorProfile: {type: Localhost, localhostProfile: book-deny-tmp}
YAML
ready_pod book-cks-host apparmor
kubectl apply -f - <<'YAML'
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata: {name: book-sandbox}
handler: runsc
---
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata: {name: book-missing}
handler: does-not-exist
YAML
kubectl label node "$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')" book-labs.example/runsc=true --overwrite
for pair in sandbox:book-sandbox missing:book-missing; do
 pod=${pair%:*};class=${pair#*:}
 kubectl -n book-cks-host delete pod "$pod" --ignore-not-found
 kubectl -n book-cks-host run "$pod" --image=busybox:1.37.0 --overrides="{\"spec\":{\"runtimeClassName\":\"$class\",\"nodeSelector\":{\"book-labs.example/runsc\":\"true\"}}}" --command -- sleep 3600
done
ready_pod book-cks-host sandbox
kubectl -n book-cks-host exec sandbox -- dmesg > "$WORK_DIR/sandbox-runtime.txt"
for n in $(seq 1 90); do
 kubectl -n book-cks-host get events --field-selector involvedObject.name=missing -o json > "$WORK_DIR/missing-runtime.txt"
 grep -q 'does-not-exist' "$WORK_DIR/missing-runtime.txt" && break
 sleep 1
done
cat > /etc/falco/rules.d/book-shell.yaml <<'YAML'
- rule: Book Interactive Container Shell
  desc: Interactive shell in an actual container
  condition: evt.type in (execve, execveat) and evt.dir=< and container.id != host and proc.name in (sh, bash, ash) and proc.tty != 0
  output: "[%evt.time.iso8601] [%container.id] [%container.name] [%proc.name]"
  priority: NOTICE
  tags: [book, shell]
YAML
python3 - <<'PYFIX'
import pathlib,yaml
p=pathlib.Path('/etc/falco/falco.yaml');d=yaml.safe_load(p.read_text());d['json_output']=True;d['rule_matching']='all';d['file_output']={'enabled':True,'keep_alive':False,'filename':'/var/log/falco/book-shell.jsonl'};rules=d.setdefault('rules_files',[])
if '/etc/falco/rules.d' not in rules:rules.append('/etc/falco/rules.d')
p.write_text(yaml.safe_dump(d))
PYFIX
falco --validate /etc/falco/rules.d/book-shell.yaml
systemctl restart book-falco
sleep 4
python3 "$(dirname "$0")/generate-shell.py"
kubectl -n book-cks-host exec shell-target -- cat /etc/hostname
sleep 3
python3 - "$WORK_DIR/falcologs.json" <<'PYEXTRACT'
import json,sys
rows=[]
for line in open('/var/log/falco/book-shell.jsonl'):
 try:d=json.loads(line)
 except ValueError:continue
 if d.get('rule')=='Book Interactive Container Shell':rows.append({'time':d['time'],'container_id':d['output_fields'].get('container.id'),'container_name':d['output_fields'].get('container.name')})
assert rows,'No actual shell event observed';json.dump(rows,open(sys.argv[1],'w'),indent=2)
PYEXTRACT
ss -lntp '( sport = :9999 )' > "$WORK_DIR/listener-before.txt"
systemctl status book-debug --no-pager > "$WORK_DIR/listener-status.txt"
printf 'book-debug.service\n' > "$WORK_DIR/listener-unit.txt"
systemctl disable --now book-debug

kube-bench run --benchmark cis-1.12 --config-dir /opt/book-tools/kube-bench/cfg --config /opt/book-tools/kube-bench/cfg/config.yaml --json > "$WORK_DIR/cis-review.json"
kubectl -n kube-system get configmap coredns -o yaml > "$WORK_DIR/coredns-review.yaml"
