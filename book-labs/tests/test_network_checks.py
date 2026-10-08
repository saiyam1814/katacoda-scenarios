"""Exercise real verifier/probe scripts with fake Kubernetes and HTTP commands."""
import collections
import json
import os
import pathlib
import subprocess
import tempfile
import time
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
FAKE_KUBECTL = r'''#!/usr/bin/env python3
import json,os,subprocess,sys
args=sys.argv[1:]
mode=os.environ['FAKE_NETWORK_MODE']
namespace=args[args.index('-n')+1] if '-n' in args else ''
if 'exec' in args:
    pod=args[args.index('exec')+1]
    if namespace=='book-cks-blue' and mode=='exec_failure':
        print('API exec failed',file=sys.stderr);sys.exit(1)
    if namespace=='book-cks-blue' and mode=='empty_exec': sys.exit(0)
    env=os.environ.copy();env.update(FAKE_NS=namespace,FAKE_POD=pod)
    result=subprocess.run(args[args.index('--')+1:],env=env)
    sys.exit(result.returncode)
resource=args[args.index('get')+1]
name=args[args.index('get')+2]
if resource=='namespace':
    result={'items':[{'metadata':{'name':'book-cks-'+team,'labels':{'team':team}}} for team in ['green','blue']]}
elif resource=='pod':
    result={'metadata':{'labels':{'access':'trusted' if name=='trusted' else 'untrusted'}},'status':{'conditions':[{'type':'Ready','status':'False' if mode=='not_ready' else 'True'}]}}
elif resource=='deployment':
    result={'metadata':{'generation':1},'spec':{'replicas':1,'template':{'spec':{'containers':[{'image':'nginx:1.28.0'}]}}},'status':{'observedGeneration':1,'availableReplicas':1,'updatedReplicas':1}}
elif resource=='service':
    result={'spec':{'selector':{'app':name},'ports':[{'port':80,'targetPort':80}],'clusterIP':'10.0.0.1' if name=='api' else '10.0.0.2'}}
else: raise AssertionError(args)
print(json.dumps(result))
'''
FAKE_WGET = r'''#!/usr/bin/env python3
import json,os,sys,time
namespace=os.environ['FAKE_NS'];pod=os.environ['FAKE_POD'];url=sys.argv[-1];mode=os.environ['FAKE_NETWORK_MODE']
record={'namespace':namespace,'pod':pod,'url':url,'args':sys.argv[1:]}
with open(os.environ['FAKE_WGET_LOG'],'a') as log: log.write(json.dumps(record)+'\n')
allowed=namespace=='book-cks-green' and pod=='trusted' and url=='http://10.0.0.1'
if mode=='wrong_peer' and namespace=='book-cks-green' and pod=='untrusted': allowed=True
if mode=='allow_broken' and allowed: allowed=False
if allowed:
    print('Welcome to nginx!');sys.exit(0)
time.sleep(float(os.environ.get('FAKE_DROP_DELAY','0')))
sys.exit(1)
'''


class NetworkCheckTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory(prefix='book-network-test-')
        self.addCleanup(self.temp.cleanup)
        self.path=pathlib.Path(self.temp.name)
        bindir=self.path/'bin';bindir.mkdir()
        for name,source in [('kubectl',FAKE_KUBECTL),('wget',FAKE_WGET)]:
            p=bindir/name;p.write_text(source);p.chmod(0o755)
        state=self.path/'state/cks-01-networkpolicy';state.mkdir(parents=True);(state/'ready').touch()
        self.env=os.environ.copy()
        self.env.update(PATH=str(bindir)+os.pathsep+self.env['PATH'],BOOK_LAB_STATE_ROOT=str(self.path/'state'),BOOK_LAB_WORK_ROOT=str(self.path/'work'),FAKE_WGET_LOG=str(self.path/'requests.jsonl'))

    def verify(self,mode,delay='0'):
        env=self.env.copy();env.update(FAKE_NETWORK_MODE=mode,FAKE_DROP_DELAY=delay)
        return subprocess.run(['bash',str(ROOT/'cks/01-networkpolicy/verify-step1.sh')],env=env,text=True,capture_output=True,timeout=12)

    def test_six_denials_and_allowed_path_run_in_parallel_under_ten_seconds(self):
        start=time.monotonic();result=self.verify('correct','2');elapsed=time.monotonic()-start
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)
        self.assertLess(elapsed,9, f'Expected parallel probes, took {elapsed:.2f}s')
        requests=[json.loads(x) for x in (self.path/'requests.jsonl').read_text().splitlines()]
        counts=collections.Counter((x['namespace'],x['pod'],x['url']) for x in requests)
        self.assertEqual(counts,{
            ('book-cks-green','trusted','http://10.0.0.1'):1,
            ('book-cks-green','untrusted','http://10.0.0.1'):2,
            ('book-cks-blue','trusted','http://10.0.0.1'):2,
            ('book-cks-green','trusted','http://10.0.0.2'):2,
        })
        self.assertTrue(all(x['args'][:3]==['-T','2','-qO-'] for x in requests))
        self.assertIn('all six denied connection attempts',result.stdout)

    def test_wrong_peer_is_rejected(self):
        result=self.verify('wrong_peer')
        self.assertNotEqual(result.returncode,0)
        self.assertIn('book-cks-green/untrusted',result.stderr)
        self.assertIn('Connection succeeded but must be denied',result.stderr)

    def test_allowed_path_must_really_work(self):
        result=self.verify('allow_broken')
        self.assertNotEqual(result.returncode,0)
        self.assertIn('Expected HTTP request failed',result.stderr)

    def test_exec_failure_cannot_count_as_network_denial(self):
        result=self.verify('exec_failure')
        self.assertNotEqual(result.returncode,0)
        self.assertIn('API exec failed',result.stderr)

    def test_zero_exit_without_remote_markers_is_rejected(self):
        result=self.verify('empty_exec')
        self.assertNotEqual(result.returncode,0)
        self.assertIn('missing remote completion markers',result.stderr)

    def test_unready_pod_fails_without_waiting_or_probing(self):
        start=time.monotonic();result=self.verify('not_ready')
        self.assertNotEqual(result.returncode,0)
        self.assertLess(time.monotonic()-start,3)
        self.assertIn('must be Ready',result.stderr)
        self.assertFalse((self.path/'requests.jsonl').exists())


if __name__=='__main__': unittest.main()
