#!/usr/bin/env python3
"""Atomically edit one static Pod; require a replacement process before readiness."""
import json, os, pathlib, subprocess, sys, tempfile, time
MANIFEST=pathlib.Path('/etc/kubernetes/manifests/kube-apiserver.yaml')
def run(args,timeout=5):
 try:return subprocess.run(args,text=True,capture_output=True,timeout=timeout)
 except subprocess.TimeoutExpired:return None
def current():
 p=run(['crictl','ps','--name','kube-apiserver','-q']);return p.stdout.splitlines()[0] if p and p.returncode==0 and p.stdout.strip() else ''
def ready(budget):
 deadline=time.monotonic()+budget
 while time.monotonic()<deadline:
  p=run(['kubectl','--request-timeout=3s','get','--raw=/readyz'],min(4,max(.1,deadline-time.monotonic())))
  if p and p.returncode==0:return
  time.sleep(1)
 raise RuntimeError('API readiness timed out; inspect crictl logs')
def patch(path):
 import yaml
 spec=json.loads(pathlib.Path(path).read_text());data=yaml.safe_load(MANIFEST.read_text());c=data['spec']['containers'][0]
 flags=spec.get('flags',{})
 command=c.get('command',[])
 for key,value in flags.items():
  command=[x for x in command if not x.startswith('--'+key+'=')]
  if value is not None:command.append('--'+key+'='+str(value))
 for key,values in spec.get('append',{}).items():
  old=next((x.split('=',1)[1] for x in command if x.startswith('--'+key+'=')), '')
  merged=list(dict.fromkeys([x for x in old.split(',') if x]+values))
  command=[x for x in command if not x.startswith('--'+key+'=')]+['--'+key+'='+','.join(merged)]
 c['command']=command
 for mount in spec.get('mounts',[]):
  name,path,readonly=mount['name'],mount['path'],mount.get('readOnly',True)
  c['volumeMounts']=[x for x in c.get('volumeMounts',[]) if x['name']!=name]+[{'name':name,'mountPath':path,'readOnly':readonly}]
  data['spec']['volumes']=[x for x in data['spec'].get('volumes',[]) if x['name']!=name]+[{'name':name,'hostPath':{'path':path,'type':mount.get('type','Directory')}}]
 fd,tmp=tempfile.mkstemp(prefix='book-api-',dir='/etc/kubernetes')
 try:
  with os.fdopen(fd,'w') as out:yaml.safe_dump(data,out,sort_keys=False)
  os.chmod(tmp,0o600);os.replace(tmp,MANIFEST)
 finally:
  if os.path.exists(tmp):os.unlink(tmp)
if __name__=='__main__':
 try:
  if sys.argv[1]=='patch':patch(sys.argv[2])
  elif sys.argv[1]=='ready':ready(float(sys.argv[2]))
  elif sys.argv[1]=='replacement':
   old=sys.argv[2]
   if not old:raise RuntimeError('Cannot verify replacement from an empty original container ID')
   deadline=time.monotonic()+float(sys.argv[3])
   while time.monotonic()<deadline:
    new=current()
    if new and new!=old:ready(max(1,deadline-time.monotonic()));break
    time.sleep(2)
   else:raise RuntimeError('API server replacement timed out; inspect crictl logs')
  else:raise RuntimeError('Unknown operation')
 except Exception as e:print('FAIL: '+str(e),file=sys.stderr);sys.exit(1)
