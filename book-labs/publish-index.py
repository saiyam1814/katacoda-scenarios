#!/usr/bin/env python3
"""Add completed labs to the flat course and catalog without including drafts.

Pass each finished path explicitly. With --all, include every complete index.
This prepares local source; it does not commit or push anything.
"""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def write(path, value):
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('paths', nargs='*')
    parser.add_argument('--all', action='store_true')
    parser.add_argument('--host', action='append', default=[], help='Mark a selected path as changing the disposable VM host')
    args = parser.parse_args()
    selected = set(args.paths)
    if args.all:
        selected.update(str(p.parent.relative_to(ROOT)) for p in ROOT.glob('*/*/index.json'))
    if not selected:
        parser.error('Specify completed paths or --all')
    course = json.loads((ROOT / 'structure.json').read_text())
    catalog = json.loads((ROOT / 'catalog.json').read_text())
    items = {item['path']: item for item in course['items']}
    labs = {lab['path']: lab for lab in catalog['labs']}
    for path in selected:
        folder = (ROOT / path).resolve()
        if not folder.is_relative_to(ROOT):
            parser.error(f'Lab path escapes the collection: {path}')
        doc = json.loads((folder / 'index.json').read_text())
        steps = doc['details']['steps']
        items[path] = {'path': path, 'title': doc['title']}
        existing = labs.get(path, {})
        identifier = existing.get('id')
        if not identifier:
            asset = doc['details']['assets']['host01'][0]['target']
            identifier = Path(asset).name
        labs[path] = {**existing, 'id': identifier, 'path': path,
                      'title': doc['title'], 'domain': doc['description'],
                      'minutes': existing.get('minutes', max(10, len(steps) * 8)),
                      'step_count': len(steps), 'backend': doc['backend']['imageid'],
                      'execution': 'host' if path in args.host else existing.get('execution', 'api')}
    paths = sorted(items, key=lambda path: ({'cka': 0, 'cks': 1, 'infrastructure': 2}.get(path.split('/')[0], 3), path))
    basenames = [Path(path).name for path in paths]
    if len(basenames) != len(set(basenames)):
        parser.error('Duplicate basenames would collide in Killercoda course routing')
    course['items'] = [items[path] for path in paths]
    course['description'] = 'CKA and CKS book practice with prepared environments, worked solutions and checks for each task.'
    catalog['updated'] = '2026-10-08'
    catalog['labs'] = [labs[path] for path in paths]
    write(ROOT / 'structure.json', course)
    write(ROOT / 'catalog.json', catalog)
    for group in sorted({path.split('/')[0] for path in paths}):
        write(ROOT / group / 'structure.json', {'items': [{'path': Path(path).name} for path in paths if path.startswith(group + '/')]})
    print(f'Indexed {len(paths)} labs; updated {len(selected)} completed source paths')


if __name__ == '__main__':
    main()
