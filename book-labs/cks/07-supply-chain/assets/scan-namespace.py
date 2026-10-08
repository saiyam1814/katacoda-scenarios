"""Run a real Trivy scan for every distinct regular/init image in the exercise namespace."""
import hashlib,json,pathlib,subprocess,sys
out=pathlib.Path(sys.argv[1]);out.mkdir(parents=True,exist_ok=True)
pods=json.loads(subprocess.check_output(['kubectl','-n','book-cks-scan','get','pods','-o','json']))
images=sorted({c['image'] for p in pods['items'] for c in p['spec'].get('containers',[])+p['spec'].get('initContainers',[])})
index={image:hashlib.sha256(image.encode()).hexdigest()[:16]+'.json' for image in images}
for image,name in index.items():
 subprocess.run(['trivy','image','--skip-db-update','--scanners','vuln','--format','json','--output',str(out/name),'--timeout','10m',image],check=True)
json.dump(index,open(out/'scan-index.json','w'),indent=2)
json.dump(pods,open(out/'pods.json','w'),indent=2)
bad=[]
for p in pods['items']:
 for c in p['spec'].get('containers',[])+p['spec'].get('initContainers',[]):
  report=json.load(open(out/index[c['image']]))
  if any(v['Severity'] in ('HIGH','CRITICAL') for r in report.get('Results',[]) for v in r.get('Vulnerabilities',[])):
   bad.append(p['metadata']['name']);break
(out/'badimages.txt').write_text(''.join(name+'\n' for name in sorted(set(bad))))
