#!/usr/bin/env python3
import json,sys
from audit_eval import level_for,validate
p=json.load(open(sys.argv[1]));validate(p)
assert set(p.get('omitStages',[]))=={'RequestReceived'}, 'Omit only RequestReceived'
checks=[]
for verb in ['get','list','watch','create','update','patch','delete','deletecollection']:
    checks.append(({'verb':verb,'group':'','resource':'secrets'},'Metadata'))
for path in ['/healthz','/healthz/ping','/readyz','/readyz/log','/livez','/livez/ping']:
    checks.append(({'verb':'get','path':path},'None'))
for verb in ['create','update','patch','delete']:
    checks.append(({'verb':verb,'group':'apps','resource':'deployments'},'RequestResponse'))
for event in [
    {'verb':'get','group':'apps','resource':'deployments'},
    {'verb':'list','group':'','resource':'pods'},
    {'verb':'create','group':'','resource':'configmaps'},
    {'verb':'get','path':'/version'},
    {'verb':'get','path':'/healthz-secret'},
    {'verb':'create','group':'batch','resource':'jobs'},
]: checks.append((event,'Metadata'))
for event,want in checks:
    got=level_for(p,event);assert got==want, f'{event}: expected {want}, got {got}'
print(f'{len(checks)} offline audit-policy cases passed')
