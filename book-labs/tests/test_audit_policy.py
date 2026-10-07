import copy,importlib.util,pathlib,unittest
path=pathlib.Path(__file__).resolve().parents[1]/'cks/06-audit-policy/assets/audit_eval.py'
spec=importlib.util.spec_from_file_location('audit_eval',path);audit=importlib.util.module_from_spec(spec);spec.loader.exec_module(audit)

def policy(rules): return {'apiVersion':'audit.k8s.io/v1','kind':'Policy','rules':rules}

class AuditPolicyTests(unittest.TestCase):
    def test_first_match_protects_secret_bodies(self):
        secret={'level':'Metadata','resources':[{'group':'','resources':['secrets']}]}
        broad={'level':'RequestResponse'}
        event={'verb':'get','group':'','resource':'secrets'}
        self.assertEqual(audit.level_for(policy([secret,broad]),event),'Metadata')
        self.assertEqual(audit.level_for(policy([broad,secret]),event),'RequestResponse')
    def test_health_path_boundary(self):
        p=policy([{'level':'None','nonResourceURLs':['/healthz','/healthz/*']},{'level':'Metadata'}])
        for path in ['/healthz','/healthz/ping']: self.assertEqual(audit.level_for(p,{'path':path}),'None')
        self.assertEqual(audit.level_for(p,{'path':'/healthz-secret'}),'Metadata')
    def test_resource_rule_cannot_swallow_nonresource_request(self):
        p=policy([{'level':'RequestResponse','resources':[{'group':'*','resources':['*']}]},{'level':'Metadata'}])
        self.assertEqual(audit.level_for(p,{'verb':'get','path':'/version'}),'Metadata')
    def test_verb_filter_and_api_group(self):
        p=policy([{'level':'RequestResponse','verbs':['create'],'resources':[{'group':'apps','resources':['deployments']}]},{'level':'Metadata'}])
        for event in [{'verb':'get','group':'apps','resource':'deployments'},{'verb':'create','group':'','resource':'deployments'}]:
            self.assertEqual(audit.level_for(p,event),'Metadata')
        self.assertEqual(audit.level_for(p,{'verb':'create','group':'apps','resource':'deployments'}),'RequestResponse')
    def test_unsupported_fields_fail_instead_of_being_silently_ignored(self):
        with self.assertRaises(AssertionError): audit.validate(policy([{'level':'Metadata','users':['alice']}]))
    def test_unmatched_event_defaults_to_none(self):
        self.assertEqual(audit.level_for(policy([{'level':'Metadata','verbs':['get']}]),{'verb':'create'}),'None')

if __name__=='__main__': unittest.main()
