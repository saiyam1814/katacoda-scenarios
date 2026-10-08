#!/usr/bin/env python3
"""Run setup -> expected failure -> solution -> expected success on an isolated cluster.
The kubeconfig is mandatory. Setup resets the selected labs' namespaces/resources.
This does not launch or publish Killercoda scenarios.
"""
import argparse,json,os,pathlib,subprocess,time
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--kubeconfig',type=pathlib.Path,required=True)
p.add_argument('--output',type=pathlib.Path,required=True)
p.add_argument('--lab',action='append',help='Lab ID; repeat to select several. Default: API-only labs.')
p.add_argument('--disposable-host',action='store_true',help='Also run host-changing labs; use only inside a disposable Linux VM.')
a=p.parse_args();root=pathlib.Path(__file__).resolve().parent
if not a.kubeconfig.is_file(): p.error('Kubeconfig does not exist')
a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=True)
env=os.environ.copy();env.update(KUBECONFIG=str(a.kubeconfig.resolve()),BOOK_LAB_WORK_ROOT=str(a.output/'work'),BOOK_LAB_STATE_ROOT=str(a.output/'state'))
catalog=json.loads((root/'catalog.json').read_text())['labs']
if a.lab:
    unknown=set(a.lab)-{x['id'] for x in catalog}
    if unknown: p.error(f'Unknown labs: {sorted(unknown)}')
    catalog=[x for x in catalog if x['id'] in a.lab]
host_labs=[x['id'] for x in catalog if x.get('execution')=='host']
if host_labs and not a.disposable_host:
    if a.lab: p.error('Host-changing labs require a disposable Linux VM and --disposable-host: '+', '.join(host_labs))
    catalog=[x for x in catalog if x.get('execution')!='host']
if a.disposable_host and os.uname().sysname!='Linux': p.error('Host-changing labs must run inside a disposable Linux VM')
report=[]
report_file=a.output/'results.json'
if report_file.is_file():
    previous=json.loads(report_file.read_text())
    selected={x['id'] for x in catalog}
    report=[x for x in previous if x['id'] not in selected]
for lab in catalog:
    item={'id':lab['id'],'checks':[]};report.append(item)
    definition=json.loads((root/lab['path']/'index.json').read_text())
    verifiers=[step['verify'] for step in definition['details']['steps']]
    actions=[('setup','setup.sh',True)]
    actions += [(f'before-step-{number}',script,False) for number,script in enumerate(verifiers,1)]
    actions += [('solution','solution.sh',True)]
    actions += [(f'after-step-{number}',script,True) for number,script in enumerate(verifiers,1)]
    for check,script,expected in actions:
        logfile=a.output/f'{lab["id"]}-{check}.log';start=time.monotonic()
        try:
            with logfile.open('w') as f: run=subprocess.run(['bash',str(root/lab['path']/script)],env=env,stdout=f,stderr=subprocess.STDOUT,timeout=900 if expected else 30)
            passed=(run.returncode==0)==expected
            result={'check':check,'exit':run.returncode,'passed':passed,'seconds':round(time.monotonic()-start,2),'log':logfile.name}
        except subprocess.TimeoutExpired:
            result={'check':check,'passed':False,'timeout':True,'log':logfile.name};passed=False
        item['checks'].append(result)
        print(lab['id'],check,'PASS' if passed else 'FAIL',flush=True)
        (a.output/'results.json').write_text(json.dumps(report,indent=2)+'\n')
        if not passed: break
raise SystemExit(0 if all(all(c['passed'] for c in x['checks']) and x['checks'][-1]['check'].startswith('after-step-') for x in report) else 1)
