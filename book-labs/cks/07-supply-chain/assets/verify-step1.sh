#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-07-supply-chain
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
python3 - "$WORK_DIR" "$STATE_DIR" <<'PYVERIFY'
import json,sys,pathlib
w,s=map(pathlib.Path,sys.argv[1:]);d=json.load(open(w/'reports/image.json'));b=json.load(open(s/'baseline-scan.json'))
assert d['ArtifactName']==b['ArtifactName'] and d['Metadata']['ImageID']==b['Metadata']['ImageID']
assert d['Metadata']['OS']['Family']=='alpine' and d['Results']
rows=['\t'.join([v['VulnerabilityID'],v['PkgName'],v['InstalledVersion'],v.get('FixedVersion','')]) for r in d['Results'] for v in r.get('Vulnerabilities',[]) if v['Severity'] in ('HIGH','CRITICAL')]
assert sorted((w/'reports/high-critical.tsv').read_text().splitlines())==sorted(rows)
# Compare scan content to the real setup scan; task outputs cannot silently omit findings.
f=lambda x: sorted((r['Target'],v['VulnerabilityID'],v['PkgName'],v['InstalledVersion']) for r in x['Results'] for v in r.get('Vulnerabilities',[]))
assert f(d)==f(b)
PYVERIFY
python3 - "$WORK_DIR/reports/namespace" "$STATE_DIR/namespace-baseline" <<'PYVERIFY'
import pathlib,json,sys,subprocess
out,base=map(pathlib.Path,sys.argv[1:]);pods=json.loads(subprocess.check_output(['kubectl','-n','book-cks-scan','get','pods','-o','json']))
images={c['image'] for p in pods['items'] for c in p['spec'].get('containers',[])+p['spec'].get('initContainers',[])}
index=json.load(open(out/'scan-index.json'));trusted=json.load(open(base/'scan-index.json'));assert set(index)==images==set(trusted)
def vulns(d):return sorted((v['VulnerabilityID'],v['PkgName'],v['InstalledVersion'],v['Severity']) for r in d.get('Results',[]) for v in r.get('Vulnerabilities',[]))
reports={}
for image,name in index.items():
 d=json.load(open(out/name));t=json.load(open(base/trusted[image]));assert d['Metadata']['ImageID']==t['Metadata']['ImageID'];assert vulns(d)==vulns(t);reports[image]=d
bad=[]
for p in pods['items']:
 if any(any(v['Severity'] in ('HIGH','CRITICAL') for r in reports[c['image']].get('Results',[]) for v in r.get('Vulnerabilities',[])) for c in p['spec'].get('containers',[])+p['spec'].get('initContainers',[])):bad.append(p['metadata']['name'])
assert (out/'badimages.txt').read_text().splitlines()==sorted(set(bad))
PYVERIFY
pass "Step 1: Scan an actual image and report exploitable priorities"
