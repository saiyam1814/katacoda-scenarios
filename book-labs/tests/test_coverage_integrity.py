"""Reject broken publication and book mappings before they reach Killercoda."""
import importlib.util
import json
from pathlib import Path
import shutil
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('lab_validator', ROOT / 'validate.py')
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)


class CoverageIntegrityTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='lab-source-integrity-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.path = 'cka/01-rbac'
        shutil.copytree(ROOT / self.path, self.root / self.path)
        self.write('structure.json', {'items': [{'path': self.path}]})
        self.write('catalog.json', {'labs': [{'id': 'cka-01-rbac', 'path': self.path}]})
        self.doc = json.loads((self.root / self.path / 'index.json').read_text())

    def write(self, name, doc):
        (self.root / name).write_text(json.dumps(doc))

    def mapping(self):
        step = self.doc['details']['steps'][0]
        return {'scenarios': [{'book': 'CKA', 'chapter': 22, 'outcome': 'Scope application access',
                              'steps': [{'lab': self.path, 'number': 1,
                                         'title': step['title'], 'verify': step['verify']}]}]}

    def test_partial_mapping_cannot_pass_full_book_validation(self):
        self.write('coverage.json', self.mapping())
        _, errors = validator.validate(self.root, require_coverage=True)
        self.assertTrue(any('Missing CKA chapters' in error for error in errors), errors)

    def test_mapping_cannot_claim_a_different_verification(self):
        mapping = self.mapping()
        mapping['scenarios'][0]['steps'][0]['verify'] = 'unpublished-check.sh'
        self.write('coverage.json', mapping)
        _, errors = validator.validate(self.root)
        self.assertTrue(any('Verifier differs' in error for error in errors), errors)

    def test_lab_cannot_be_omitted_from_the_published_course(self):
        self.write('structure.json', {'items': []})
        _, errors = validator.validate(self.root)
        self.assertTrue(any('include every lab' in error for error in errors), errors)

    def test_duplicate_flat_route_is_rejected(self):
        shutil.copytree(self.root / self.path, self.root / 'cks/01-rbac')
        self.write('structure.json', {'items': [{'path': self.path}, {'path': 'cks/01-rbac'}]})
        self.write('catalog.json', {'labs': [{'id': 'cka-01-rbac', 'path': self.path},
                                            {'id': 'cks-01-rbac', 'path': 'cks/01-rbac'}]})
        _, errors = validator.validate(self.root)
        self.assertTrue(any('globally unique' in error for error in errors), errors)


if __name__ == '__main__':
    unittest.main()
