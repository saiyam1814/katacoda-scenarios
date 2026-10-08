#!/usr/bin/env python3
"""Check published scenario definitions and exact book-to-step references.

This checks source integrity only. Hosted CHECK results are recorded separately.
"""
import argparse
import json
import pathlib
import subprocess
import sys

BACKENDS = {
    'ubuntu', 'ubuntu-4GB', 'kubernetes-kubeadm-1node',
    'kubernetes-kubeadm-1node-4GB', 'kubernetes-kubeadm-2nodes',
}
BOOK_CHAPTERS = {'CKA': 38, 'CKS': 31}


def local_file(folder, name):
    target = (folder / name).resolve()
    assert target.is_relative_to(folder.resolve()), f'Path escapes lab: {name}'
    assert target.is_file(), f'Missing referenced file: {name}'
    return target


def validate(root, require_coverage=False):
    root = root.resolve()
    errors = []
    indices = sorted(root.glob('*/*/index.json'))
    definitions = {}
    if not indices:
        errors.append('No lab definitions found')
    for path in indices:
        folder = path.parent
        relative = str(folder.relative_to(root))
        try:
            doc = json.loads(path.read_text())
            details = doc['details']
            assert doc['backend']['imageid'] in BACKENDS, 'Unsupported backend image'
            assert isinstance(details['steps'], list) and details['steps'], 'Lab has no steps'
            for section in [details['intro'], *details['steps'], details['finish']]:
                local_file(folder, section['text'])
                for key in ('background', 'foreground', 'verify'):
                    if key in section:
                        local_file(folder, section[key])
            for step in details['steps']:
                assert step.get('title'), 'Step has no title'
                assert step.get('verify'), f'Step has no verification: {step["title"]}'
            delivered = set()
            for host, entries in details['assets'].items():
                assert host in {'host01', 'host02'}, f'Unsupported asset host: {host}'
                assert isinstance(entries, list) and entries, f'No assets on {host}'
                for entry in entries:
                    assert not pathlib.PurePosixPath(entry['file']).is_absolute(), 'Absolute asset pattern'
                    matches = list((folder / 'assets').glob(entry['file']))
                    assert matches, f'Asset pattern matches nothing: {entry["file"]}'
                    assert entry['target'].startswith('/opt/book-labs/'), 'Assets must use the isolated book-labs directory'
                    for match in matches:
                        assert match.resolve().is_relative_to((folder / 'assets').resolve()), 'Asset escapes folder'
                        if match.is_file():
                            delivered.add(match.name)
            for name in ('setup.sh', 'solution.sh'):
                assert name in delivered, f'Undelivered asset: {name}'
            for script in folder.rglob('*.sh'):
                result = subprocess.run(['bash', '-n', str(script)], capture_output=True, text=True)
                assert result.returncode == 0, result.stderr.strip()
            definitions[relative] = doc
        except (KeyError, ValueError, TypeError, AssertionError, OSError) as error:
            errors.append(f'{relative}: {error}')

    for path in root.rglob('structure.json'):
        try:
            doc = json.loads(path.read_text())
            seen = set()
            for item in doc['items']:
                target = (path.parent / item['path']).resolve()
                assert target.is_relative_to(root), 'Course path escapes book-labs'
                assert target.is_dir() and (target / 'index.json').is_file(), f'Course item must reference a lab: {item["path"]}'
                assert target not in seen, f'Duplicate course item: {item["path"]}'
                seen.add(target)
            if path == root / 'structure.json':
                assert seen == {p.parent for p in indices}, 'Root course must include every lab exactly once'
                basenames = [p.name for p in seen]
                assert len(basenames) == len(set(basenames)), 'Course routing requires globally unique lab basenames'
        except (KeyError, ValueError, TypeError, AssertionError, OSError) as error:
            errors.append(f'{path.relative_to(root)}: {error}')

    catalog_path = root / 'catalog.json'
    if catalog_path.exists():
        try:
            catalog = json.loads(catalog_path.read_text())['labs']
            assert len({lab['id'] for lab in catalog}) == len(catalog), 'Duplicate catalog IDs'
            assert {lab['path'] for lab in catalog} == {str(p.parent.relative_to(root)) for p in indices}, 'Catalog and lab folders differ'
        except (KeyError, ValueError, TypeError, AssertionError) as error:
            errors.append(f'catalog.json: {error}')

    coverage_path = root / 'coverage.json'
    if coverage_path.exists():
        try:
            coverage = json.loads(coverage_path.read_text())
            found = {book: set() for book in BOOK_CHAPTERS}
            for scenario in coverage['scenarios']:
                book = scenario['book']
                chapter = scenario['chapter']
                assert book in BOOK_CHAPTERS and isinstance(chapter, int) and 1 <= chapter <= BOOK_CHAPTERS[book], f'Invalid chapter: {book} {chapter}'
                assert scenario.get('outcome'), f'No learning outcome: {book} {chapter}'
                assert scenario.get('steps'), f'No mapped steps: {book} {chapter}'
                for reference in scenario['steps']:
                    definition = definitions[reference['lab']]
                    number = reference['number']
                    assert isinstance(number, int) and 1 <= number <= len(definition['details']['steps']), f'Invalid step: {reference}'
                    actual = definition['details']['steps'][number - 1]
                    assert reference['verify'] == actual['verify'], f'Verifier differs from published step: {reference}'
                    assert reference['title'] == actual['title'], f'Title differs from published step: {reference}'
                assert chapter not in found[book], f'Duplicate chapter record: {book} {chapter}'
                found[book].add(chapter)
            if require_coverage:
                for book, count in BOOK_CHAPTERS.items():
                    missing = set(range(1, count + 1)) - found[book]
                    assert not missing, f'Missing {book} chapters: {sorted(missing)}'
        except (KeyError, ValueError, TypeError, AssertionError, OSError) as error:
            errors.append(f'coverage.json: {error}')
    elif require_coverage:
        errors.append('coverage.json is required for full-book validation')

    for path in root.rglob('*.py'):
        try:
            compile(path.read_text(), str(path), 'exec')
        except (SyntaxError, UnicodeDecodeError) as error:
            errors.append(str(error))
    return indices, errors


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=pathlib.Path, default=pathlib.Path(__file__).resolve().parent)
    parser.add_argument('--require-coverage', action='store_true', help='Require all 38 CKA and 31 CKS chapter mappings')
    args = parser.parse_args()
    indices, errors = validate(args.root, args.require_coverage)
    if errors:
        print('\n'.join(errors), file=sys.stderr)
        sys.exit(1)
    print(f'PASS: {len(indices)} lab definitions, supported backends, step checks, local references, course paths, asset delivery and script syntax')
    if args.require_coverage:
        print('PASS: all 69 book scenarios map to published steps and their actual verification scripts')
