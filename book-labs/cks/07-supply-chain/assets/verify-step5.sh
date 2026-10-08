#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-07-supply-chain
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
python3 - "$WORK_DIR/reports" <<'PYVERIFY'
import json,pathlib,sys
p=pathlib.Path(sys.argv[1]);s=json.load(open(p/'sbom.cdx.json'));d=json.load(open(p/'sbom-scan.json'));image=json.load(open(p/'image.json'))
assert s['bomFormat']=='CycloneDX' and len(s.get('components',[]))>0 and 'metadata' in s
assert any(c.get('name')=='busybox' for c in s['components'])
f=lambda x:set((v['VulnerabilityID'],v['PkgName']) for r in x.get('Results',[]) for v in r.get('Vulnerabilities',[]))
assert f(d)==f(image)
blocked=any(v['Severity'] in ('HIGH','CRITICAL') for r in d.get('Results',[]) for v in r.get('Vulnerabilities',[]))
assert (p/'decision.txt').read_text().strip()==('BLOCK' if blocked else 'PASS')
PYVERIFY
pass "Step 5: Generate an SBOM and make an evidence-based release decision"
