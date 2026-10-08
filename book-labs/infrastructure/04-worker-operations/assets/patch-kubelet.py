import pathlib,sys,yaml
p=pathlib.Path('/var/lib/kubelet/config.yaml');d=yaml.safe_load(p.read_text());secure=sys.argv[1]=='secure'
d.setdefault('authentication',{}).setdefault('anonymous',{})['enabled']=not secure
d['authentication'].setdefault('webhook',{})['enabled']=True
d.setdefault('authorization',{})['mode']='Webhook' if secure else 'AlwaysAllow'
d['readOnlyPort']=0 if secure else 10255
p.write_text(yaml.safe_dump(d,sort_keys=False))
