#!/usr/bin/env python3
"""Offline evaluator for the deliberately restricted audit-policy subset in this lab.
This is NOT Kubernetes audit-policy validation or a replacement for kube-apiserver tests.
JSON is valid YAML and avoids an extra YAML dependency in the lab environment.
"""
import json
LEVELS={'None','Metadata','Request','RequestResponse'}
def validate(policy):
    assert set(policy) <= {'apiVersion','kind','omitStages','rules'}, 'Unsupported policy key'
    assert policy.get('apiVersion')=='audit.k8s.io/v1' and policy.get('kind')=='Policy'
    assert isinstance(policy.get('rules'),list) and policy['rules'], 'Policy needs rules'
    assert set(policy.get('omitStages',[])) <= {'RequestReceived','ResponseStarted','ResponseComplete','Panic'}
    for rule in policy['rules']:
        assert set(rule) <= {'level','verbs','resources','nonResourceURLs'}, 'Unsupported rule field for this exercise'
        assert rule.get('level') in LEVELS
        assert not ('resources' in rule and 'nonResourceURLs' in rule)
        for resource in rule.get('resources',[]):
            assert set(resource) <= {'group','resources'}
            assert isinstance(resource.get('group',''),str)
            assert isinstance(resource.get('resources'),list) and resource['resources']
        for url in rule.get('nonResourceURLs',[]):
            assert '*' not in url[:-1], 'Only a terminal wildcard is supported'
def level_for(policy,event):
    validate(policy)
    for rule in policy['rules']:
        if 'verbs' in rule and event.get('verb') not in rule['verbs'] and '*' not in rule['verbs']: continue
        if 'nonResourceURLs' in rule:
            if event.get('resource') is not None: continue
            url=event.get('path','')
            if not any(url==pat or (pat.endswith('*') and url.startswith(pat[:-1])) for pat in rule['nonResourceURLs']): continue
        if 'resources' in rule:
            if event.get('resource') is None: continue
            group=event.get('group','');resource=event['resource']
            if not any(r.get('group','') in (group,'*') and (resource in r['resources'] or '*' in r['resources']) for r in rule['resources']): continue
        return rule['level']
    return 'None'
if __name__=='__main__':
    import sys
    p=json.load(open(sys.argv[1]));e=json.load(open(sys.argv[2]));print(level_for(p,e))
