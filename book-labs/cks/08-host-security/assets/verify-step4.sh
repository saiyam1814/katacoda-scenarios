#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-08-host-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
systemctl is-active --quiet book-falco
python3 - "$WORK_DIR/falcologs.json" "$(dirname "$0")/generate-shell.py" <<'PYVERIFY'
import json,sys,subprocess,time,pathlib
p=pathlib.Path('/var/log/falco/book-shell.jsonl');offset=p.stat().st_size
cid=json.loads(subprocess.check_output(['kubectl','-n','book-cks-host','get','pod','shell-target','-o','json']))['status']['containerStatuses'][0]['containerID'].split('://')[-1]
subprocess.run(['python3',sys.argv[2]],check=True,timeout=4)
subprocess.run(['kubectl','-n','book-cks-host','exec','shell-target','--','cat','/etc/hostname'],check=True,stdout=subprocess.DEVNULL,timeout=3)
time.sleep(1.5)
with p.open() as f:f.seek(offset);lines=f.readlines()
rows=[]
for line in lines:
 try:d=json.loads(line)
 except ValueError:continue
 if d.get('rule')=='Book Interactive Container Shell':rows.append(d)
matched=[d for d in rows if cid.startswith(d['output_fields'].get('container.id','NO_MATCH'))]
assert matched,'No fresh TTY-shell event for the target container'
assert all(d['output_fields'].get('proc.name') in ('sh','bash','ash') for d in matched)
assert all(d['output_fields'].get('container.name') not in (None,'','<NA>','host') for d in matched),'Fix actual runtime metadata enrichment'
saved=json.load(open(sys.argv[1]));assert any(x.get('time') and cid.startswith(x.get('container_id','NO_MATCH')) and x.get('container_name') not in (None,'','<NA>') for x in saved)
PYVERIFY
pass "Step 4: Detect an actual interactive container shell with Falco"
