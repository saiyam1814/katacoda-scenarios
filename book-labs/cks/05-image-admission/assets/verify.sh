#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-05-image-admission
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl get validatingadmissionpolicy book-images -o json | json_assert 'd["spec"].get("failurePolicy") == "Fail"' 'Policy must fail closed'
kubectl get validatingadmissionpolicybinding book-images -o json | json_assert 'd["spec"]["policyName"] == "book-images" and set(d["spec"]["validationActions"]) == {"Deny"} and d["spec"]["matchResources"]["namespaceSelector"]["matchLabels"] == {"book-labs.example/image-policy":"enforce"}' 'Binding must deny and target only the labeled namespace'
python3 - <<'PYPROBE'
import copy,json,subprocess,time
image='registry.k8s.io/pause@sha256:'+'a'*64
base={'apiVersion':'v1','kind':'Pod','metadata':{'name':'image-check','namespace':'book-cks-images'},'spec':{'containers':[{'name':'app','image':image}]}}
def run(obj): return subprocess.run(['kubectl','create','--dry-run=server','-f','-'],input=json.dumps(obj),text=True,capture_output=True)
# Admission configuration propagates asynchronously.
bad=copy.deepcopy(base);bad['spec']['containers'][0]['image']='nginx:latest'
for _ in range(30):
    p=run(bad)
    if p.returncode and 'book-images' in p.stderr: break
    time.sleep(1)
else: raise AssertionError('Policy did not reject a foreign mutable image')
cases=[(base,True)]
for ref in ['registry.k8s.io/pause:3.10','registry.k8s.io/pause','docker.io/library/nginx@sha256:'+'a'*64,'registry.k8s.io.evil.example/pause@sha256:'+'a'*64,'registry.k8s.io/pause@sha256:abc']:
    obj=copy.deepcopy(base);obj['spec']['containers'][0]['image']=ref;cases.append((obj,False))
init=copy.deepcopy(base);init['spec']['initContainers']=[{'name':'init','image':'busybox:1.37.0','command':['true']}];cases.append((init,False))
init_ok=copy.deepcopy(init);init_ok['spec']['initContainers'][0]['image']=image;cases.append((init_ok,True))
outside=copy.deepcopy(bad);outside['metadata']['namespace']='book-cks-images-outside';cases.append((outside,True))
for obj,allowed in cases:
    p=run(obj);assert (p.returncode==0)==allowed, p.stderr or p.stdout
    if not allowed: assert 'book-images' in p.stderr, 'Rejection was not caused by the image policy: '+p.stderr
# Structural match coverage ensures UPDATE is not accidentally omitted.
p=subprocess.run(['kubectl','get','validatingadmissionpolicy','book-images','-o','json'],check=True,text=True,capture_output=True)
rules=json.loads(p.stdout)['spec']['matchConstraints']['resourceRules']
assert any(('UPDATE' in r['operations'] or '*' in r['operations']) and 'pods' in r['resources'] for r in rules), 'Match UPDATE requests as well'
PYPROBE
pass "All checks passed for cks-05-image-admission"
