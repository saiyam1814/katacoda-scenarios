import json,pathlib,subprocess,sys,time,uuid,yaml
stopped=False
def pod(image,name):
 return subprocess.run(['kubectl','--request-timeout=3s','run',name,'-n','cks16','--image='+image,'--restart=Never','--dry-run=server','-o','json'],capture_output=True,text=True,timeout=4)
try:
 conf=yaml.safe_load(pathlib.Path('/etc/kubernetes/image-policy/admission.yaml').read_text())
 policy=next(p for p in conf['plugins'] if p['name']=='ImagePolicyWebhook')['configuration']['imagePolicy']
 if policy.get('defaultAllow') is not False or policy.get('allowTTL')!=1 or policy.get('denyTTL')!=1:raise ValueError('configure fail-closed behavior and 1-second cache TTLs')
 p=subprocess.run(['kubectl','--request-timeout=3s','get','pod','allowed','-n','cks16','-o','json'],capture_output=True,text=True,timeout=4)
 if p.returncode:raise ValueError('allowed Pod is missing')
 obj=json.loads(p.stdout)
 if not any(c['type']=='Ready' and c['status']=='True' for c in obj.get('status',{}).get('conditions',[])):raise ValueError('allowed Pod is not Ready')
 tag=uuid.uuid4().hex[:8]
 allowed=pod('busybox:1.37.0','allowed-'+tag)
 if allowed.returncode:raise ValueError('approved request failed: '+allowed.stderr.strip())
 denied=pod('busybox:latest','denied-'+tag)
 if denied.returncode==0 or 'cks16 exact image allowlist' not in denied.stderr:raise ValueError('unapproved image did not receive the webhook policy denial')
 subprocess.run(['systemctl','stop','cks16-policy'],check=True,timeout=3);stopped=True
 time.sleep(1.1)
 # Admission protects new objects; a running workload must still execute while
 # the policy endpoint is unavailable. Exercise that behavior during the outage.
 survivor=subprocess.run(['kubectl','--request-timeout=3s','exec','allowed','-n','cks16','--','printf','existing-pod-still-running'],capture_output=True,text=True,timeout=4)
 if survivor.returncode or survivor.stdout!='existing-pod-still-running':raise ValueError('existing Pod execution failed during policy outage: '+survivor.stderr.strip())
 outage=pod('nginx:1.28.0-alpine','outage-'+tag)
 if outage.returncode==0:raise ValueError('request was accepted during webhook outage')
 if 'context deadline exceeded' in outage.stderr or not any(t in outage.stderr.lower() for t in ('imagepolicy','image policy','connection refused')):raise ValueError('outage request failed for an unrelated reason: '+outage.stderr.strip())
 subprocess.run(['systemctl','start','cks16-policy'],check=True,timeout=3);stopped=False
 # The endpoint is local, but allow a short socket startup interval before API retry.
 time.sleep(.3)
 recovered=pod('busybox:1.37.0','recovered-'+tag)
 if recovered.returncode:raise ValueError('approved admission did not recover')
 print('PASS: approved/denied images, fail-closed outage, existing Pod execution and recovered admission verified')
except Exception as e:sys.exit('FAIL: '+str(e))
finally:
 if stopped:subprocess.run(['systemctl','start','cks16-policy'],timeout=5)
