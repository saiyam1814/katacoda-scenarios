#!/usr/bin/env python3
"""Prove the network checker rejects the common namespaceSelector OR podSelector mistake."""
import argparse,json,os,pathlib,subprocess
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--kubeconfig',type=pathlib.Path,required=True);p.add_argument('--smoke-output',type=pathlib.Path,required=True);a=p.parse_args()
root=pathlib.Path(__file__).resolve().parents[1];out=a.smoke_output.resolve();env=os.environ.copy();env.update(KUBECONFIG=str(a.kubeconfig.resolve()),BOOK_LAB_STATE_ROOT=str(out/'state'),BOOK_LAB_WORK_ROOT=str(out/'work'))
assert (out/'state/cks-01-networkpolicy/ready').is_file(), 'Run the network smoke test first'
lab=root/'cks/01-networkpolicy'
def run(action): return subprocess.run(['bash',str(lab/(action+'.sh'))],env=env,capture_output=True,text=True,timeout=180)
baseline=run('verify');assert baseline.returncode==0, baseline.stdout+baseline.stderr
wrong={'spec':{'ingress':[{'from':[{'namespaceSelector':{'matchLabels':{'team':'green'}}},{'podSelector':{'matchLabels':{'access':'trusted'}}}],'ports':[{'protocol':'TCP','port':80}]}]}}
try:
    subprocess.run(['kubectl','-n','book-cks-network','patch','networkpolicy','allow-green-trusted','--type=merge','-p',json.dumps(wrong)],env=env,check=True,capture_output=True)
    r=run('verify');assert r.returncode!=0, 'OR selector error was accepted'
    assert 'book-cks-green/untrusted' in r.stderr, r.stdout+r.stderr
finally:
    r=run('solution');assert r.returncode==0,r.stdout+r.stderr
r=run('verify');assert r.returncode==0,r.stdout+r.stderr
(out/'network-mutation.json').write_text(json.dumps({'id':'cks-01-networkpolicy','mutation':'namespaceSelector and podSelector split into separate OR peers','rejected':True,'restored_and_verified':True},indent=2)+'\n')
print('PASS: OR peer mistake rejected; correct AND policy restored and verified')
