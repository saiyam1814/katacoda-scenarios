#!/usr/bin/env python3
"""Reject common wrong answers after successful smoke tests. Disposable cluster only."""
import argparse,json,os,pathlib,subprocess
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--kubeconfig',type=pathlib.Path,required=True);p.add_argument('--smoke-output',type=pathlib.Path,required=True)
a=p.parse_args();root=pathlib.Path(__file__).resolve().parents[1];env=os.environ.copy();out=a.smoke_output.resolve()
env.update(KUBECONFIG=str(a.kubeconfig.resolve()),BOOK_LAB_STATE_ROOT=str(out/'state'),BOOK_LAB_WORK_ROOT=str(out/'work'))
# All mutations are within lab resources prepared by smoke-test.py. Every test restores its change.
def k(*args): subprocess.run(['kubectl',*args],check=True,env=env,capture_output=True,text=True)
def patch(ns,kind,name,body): k('-n',ns,'patch',kind,name,'--type=merge','-p',json.dumps(body))
def verify(path): return subprocess.run(['bash',str(root/path/'verify.sh')],env=env,capture_output=True,text=True,timeout=180)
results=[]
def case(name,path,change,restore):
    assert (out/'state'/name/'ready').is_file(), f'Run smoke tests first: {name}'
    baseline=verify(path);assert baseline.returncode==0,baseline.stdout+baseline.stderr
    try:
        change();r=verify(path);assert r.returncode!=0, f'{name}: incorrect state passed'
        results.append({'id':name,'mutation_rejected':True})
        print(name,'wrong answer rejected',flush=True)
    finally: restore()
    r=verify(path);assert r.returncode==0,r.stdout+r.stderr

def role(r): patch('book-cka-rbac','role','release-manager',{'rules':r})
correct=[{'apiGroups':['apps'],'resources':['deployments'],'verbs':['get','list','watch','update','patch']},{'apiGroups':[''],'resources':['configmaps'],'verbs':['get','list','watch']}]
case('cka-01-rbac','cka/01-rbac',lambda:role([{'apiGroups':['*'],'resources':['*'],'verbs':['*']}]),lambda:role(correct))
case('cka-01-rbac','cka/01-rbac',lambda:k('create','clusterrolebinding','book-labs-qa-group','--clusterrole=cluster-admin','--group=system:serviceaccounts:book-cka-rbac'),lambda:k('delete','clusterrolebinding','book-labs-qa-group','--ignore-not-found'))
case('cka-02-service-repair' ,'cka/02-service-repair',lambda:patch('book-cka-service','service','web',{'spec':{'ports':[{'name':'http','port':80,'targetPort':81}]}}),lambda:patch('book-cka-service','service','web',{'spec':{'ports':[{'name':'http','port':80,'targetPort':80}]}}))
case('cka-03-kustomize','cka/03-kustomize',lambda:patch('book-cka-kustomize','deployment','prod-web',{'spec':{'replicas':2}}),lambda:patch('book-cka-kustomize','deployment','prod-web',{'spec':{'replicas':3}}))
case('cka-04-persistent-volume','cka/04-persistent-volume',lambda:k('-n','book-cka-storage','exec','writer','--','sh','-c','printf wrong > /data/proof.txt'),lambda:k('-n','book-cka-storage','exec','writer','--','sh','-c','printf book-data-survives > /data/proof.txt'))
case('cka-06-rollout-recovery','cka/06-rollout-recovery',lambda:patch('book-cka-rollout','deployment','web',{'spec':{'replicas':3}}),lambda:patch('book-cka-rollout','deployment','web',{'spec':{'replicas':2}}))
case('cks-02-pod-security','cks/02-pod-security',lambda:k('label','ns','book-cks-psa','pod-security.kubernetes.io/enforce=privileged','--overwrite'),lambda:k('label','ns','book-cks-psa','pod-security.kubernetes.io/enforce=restricted','--overwrite'))
case('cks-04-serviceaccount','cks/04-serviceaccount',lambda:patch('book-cks-identity','serviceaccount','reader',{'automountServiceAccountToken':True}),lambda:patch('book-cks-identity','serviceaccount','reader',{'automountServiceAccountToken':False}))
case('cks-05-image-admission','cks/05-image-admission',lambda:k('patch','validatingadmissionpolicybinding','book-images','--type=merge','-p','{"spec":{"validationActions":["Audit"]}}'),lambda:k('patch','validatingadmissionpolicybinding','book-images','--type=merge','-p','{"spec":{"validationActions":["Deny"]}}'))
(out/'mutations.json').write_text(json.dumps(results,indent=2)+'\n')
print(f'{len(results)} live wrong-answer mutation tests passed')
