#!/usr/bin/env bash
LAB_ID=infra-09-host-hardening
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
systemctl is-active --quiet cks31-report || fail 'The reporting service is not running'
pid=$(systemctl show -p MainPID --value cks31-report)
test "$pid" -gt 1 || fail 'Missing service process'
python3 - "$pid" <<'EOF'
import pathlib,pwd,sys,subprocess,os
pid=sys.argv[1];d=dict(line.split(':',1) for line in pathlib.Path('/proc/'+pid+'/status').read_text().splitlines() if ':' in line)
uid=pwd.getpwnam('cks31').pw_uid;gid=pwd.getpwnam('cks31').pw_gid
checks=[set(os.getgrouplist('cks31',gid)).issubset({gid}),all(int(x)==uid for x in d['Uid'].split()),all(int(x)==gid for x in d['Gid'].split()),d['NoNewPrivs'].strip()=='1',int(d['CapEff'].strip(),16)==0,int(d['CapBnd'].strip(),16)==0,set(map(int,d['Groups'].split())).issubset({gid})]
props=dict(line.split('=',1) for line in subprocess.check_output(['systemctl','show','cks31-report','-p','ProtectSystem','-p','PrivateTmp','-p','ProtectHome','-p','RestrictSUIDSGID','-p','ReadWritePaths'],text=True).splitlines())
checks += [props['ProtectSystem']=='strict',props['PrivateTmp']=='yes',props['ProtectHome']=='yes',props['RestrictSUIDSGID']=='yes',props['ReadWritePaths']=='/var/lib/cks31']
if not all(checks):sys.exit('FAIL: live process identity or systemd protection settings are incomplete')
EOF
body=$(curl --noproxy '*' -fsS --max-time 2 http://127.0.0.1:9998/)
[[ "$body" == 'cks31 report' ]] || fail 'Unexpected localhost report'
if curl --noproxy '*' -fsS --max-time 2 "http://$(cat "$STATE_DIR/host-ip"):9998/" >/dev/null 2>&1; then fail 'Service is still reachable through the non-loopback address'; fi
# Failure must be read-only filesystem, not a missing command or bad PID.
if nsenter -t "$pid" -m -- touch /etc/cks31-must-fail 2>"$STATE_DIR/fs-denial"; then rm -f /etc/cks31-must-fail; fail 'Service mount namespace permits an /etc write'; fi
grep -qi 'read-only file system' "$STATE_DIR/fs-denial" || fail 'Filesystem probe failed for an unexpected reason'
nsenter -t "$pid" -m -- runuser -u cks31 -- touch /var/lib/cks31/allowed || fail 'State directory is not writable by the service identity'
pass 'Real service identity, HTTP exposure, privileges and filesystem isolation verified'
