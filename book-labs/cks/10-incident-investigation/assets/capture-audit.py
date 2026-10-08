import pathlib,json,sys
rows=[]
for line in pathlib.Path('/var/log/book-incident-audit/audit.jsonl').read_text().splitlines():
 try:d=json.loads(line)
 except ValueError:continue
 if d.get('stage')=='ResponseComplete' and d.get('user',{}).get('username')=='system:serviceaccount:book-cks-incident:actor':rows.append(d)
needed={('get','book-cks-incident','secrets','payments',200),('list','kube-system','secrets',None,403),('delete','book-cks-incident','pods','victim',200)}
found=set()
for d in rows:
 o=d.get('objectRef',{});found.add((d['verb'],o.get('namespace'),o.get('resource'),o.get('name'),d.get('responseStatus',{}).get('code')))
assert needed<=found, ('Waiting for actual audit records',needed-found)
pathlib.Path(sys.argv[1]).write_text(''.join(json.dumps(x)+'\n' for x in rows))
