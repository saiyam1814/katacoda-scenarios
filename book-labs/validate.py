#!/usr/bin/env python3
"""Offline integrity checks; this does not certify live Kubernetes behavior."""
import argparse,json,pathlib,subprocess,sys

def validate(root):
    errors=[];indices=sorted(root.glob('*/*/index.json')); common=[]
    if len(indices)!=12: errors.append(f'Expected 12 labs, found {len(indices)}')
    for path in indices:
        folder=path.parent
        try:
            doc=json.loads(path.read_text()); details=doc['details']
            assert doc['backend']['imageid']=='kubernetes-kubeadm-1node'
            for section in [details['intro'],*details['steps'],details['finish']]:
                for key in ('text','background','foreground','verify'):
                    if key in section:
                        target=(folder/section[key]).resolve()
                        assert target.is_relative_to(folder.resolve()), f'Path escapes lab: {section[key]}'
                        assert target.is_file(), f'Missing referenced {key}: {target}'
            delivered=[]
            for entry in details['assets']['host01']:
                matches=list((folder/'assets').glob(entry['file']))
                assert matches, f'Asset pattern matches nothing: {entry}'
                assert entry['target'].startswith('/opt/book-labs/')
                delivered.extend(x.name for x in matches if x.is_file())
            for name in ['lib.sh','setup.sh','verify.sh','solution.sh']:
                assert name in delivered, f'Undelivered asset: {name}'
            for script in folder.rglob('*.sh'):
                p=subprocess.run(['bash','-n',str(script)],capture_output=True,text=True)
                assert p.returncode==0, p.stderr
            common.append((folder/'assets/lib.sh').read_bytes())
        except (KeyError,ValueError,AssertionError) as e: errors.append(f'{folder.relative_to(root)}: {e}')
    if common and any(s!=common[0] for s in common): errors.append('Duplicated common lib.sh files have diverged')
    for path in root.rglob('structure.json'):
        try:
            doc=json.loads(path.read_text())
            for item in doc['items']:
                target=path.parent/item['path']
                assert target.is_dir() and (target/'index.json').is_file(), f'Course item must reference a scenario with index.json, not another group: {target}'
        except (KeyError,ValueError,AssertionError) as e: errors.append(f'{path}: {e}')
    for path in root.rglob('*.py'):
        if path==pathlib.Path(__file__): continue
        try: compile(path.read_text(),str(path),'exec')
        except SyntaxError as e: errors.append(str(e))
    return indices,errors

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--root',type=pathlib.Path,default=pathlib.Path(__file__).resolve().parent)
    args=parser.parse_args();indices,errors=validate(args.root)
    if errors:
        print('\n'.join(errors),file=sys.stderr);sys.exit(1)
    print(f'PASS: {len(indices)} lab definitions, local references, group paths, asset delivery, Bash and Python syntax')
