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
pass "Step 1: Scan an actual image and report exploitable priorities"
