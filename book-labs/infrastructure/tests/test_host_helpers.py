#!/usr/bin/env python3
"""Focused helper regressions; these do not count as live chapter coverage."""
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]

class ImagePolicyURLTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        source = (ROOT / '07-apiserver-security/assets/imagepolicy-webhook.py').read_text()
        namespace = {}
        # Load the actual handler, but do not bind a socket in a unit test.
        exec(compile(source.split('server = HTTPServer', 1)[0], '<handler>', 'exec'), namespace)
        cls.handler = namespace['Handler']

    def request(self, path, image, namespace='cks16'):
        body = json.dumps({'spec': {'namespace': namespace, 'containers': [{'image': image}]}}).encode()
        request = self.handler.__new__(self.handler)
        request.path = path
        request.headers = {'Content-Length': str(len(body))}
        request.rfile, request.wfile = io.BytesIO(body), io.BytesIO()
        statuses = []
        request.send_response = statuses.append
        request.send_error = statuses.append
        request.send_header = lambda *args: None
        request.end_headers = lambda: None
        request.do_POST()
        return statuses[0], json.loads(request.wfile.getvalue()) if request.wfile.getvalue() else None

    def test_api_timeout_query_is_accepted(self):
        status, result = self.request('/check?timeout=30s', 'busybox:1.37.0')
        self.assertEqual(status, 200)
        self.assertTrue(result['status']['allowed'])

    def test_query_does_not_bypass_image_denial(self):
        status, result = self.request('/check?timeout=30s', 'busybox:latest')
        self.assertEqual(status, 200)
        self.assertFalse(result['status']['allowed'])

    def test_unrelated_namespaces_remain_available(self):
        _, result = self.request('/check?timeout=30s', 'registry.k8s.io/pause:3.10', 'kube-system')
        self.assertTrue(result['status']['allowed'])

    def test_wrong_endpoint_is_rejected(self):
        self.assertEqual(self.request('/unknown?timeout=30s', 'busybox:1.37.0')[0], 404)

class ManifestPatchTests(unittest.TestCase):
    def test_preserves_flags_mounts_other_container_and_is_idempotent(self):
        try:
            import yaml
        except ImportError:
            self.skipTest('PyYAML is a declared host setup dependency; run inside the lab or a Python environment containing it')
        path = ROOT / '07-apiserver-security/assets/controlplane.py'
        spec = importlib.util.spec_from_file_location('book_controlplane', path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        with tempfile.TemporaryDirectory() as directory:
            directory = Path(directory)
            manifest = directory / 'kube-apiserver.yaml'
            manifest.write_text(yaml.safe_dump({'apiVersion': 'v1', 'kind': 'Pod', 'spec': {'containers': [
                {'name': 'kube-apiserver', 'command': ['kube-apiserver', '--client-ca-file=/original/ca', '--enable-admission-plugins=NodeRestriction'], 'volumeMounts': [{'name': 'pki', 'mountPath': '/original'}]},
                {'name': 'retained', 'command': ['unchanged']}], 'volumes': [{'name': 'pki', 'hostPath': {'path': '/original', 'type': 'Directory'}}]}}))
            patch = directory / 'patch.json'
            patch.write_text(json.dumps({'flags': {'audit-log-path': '/audit/events'}, 'append': {'enable-admission-plugins': ['ImagePolicyWebhook']}, 'mounts': [{'name': 'audit', 'path': '/audit', 'readOnly': False}]}))
            module.MANIFEST = manifest
            real_mkstemp = tempfile.mkstemp
            def in_scratch(**kwargs):
                kwargs['dir'] = directory
                return real_mkstemp(**kwargs)
            with mock.patch.object(module.tempfile, 'mkstemp', side_effect=in_scratch):
                module.patch(str(patch))
                first = manifest.read_text()
                module.patch(str(patch))
                self.assertEqual(first, manifest.read_text())
            result = yaml.safe_load(first)
            api = result['spec']['containers'][0]
            self.assertIn('--client-ca-file=/original/ca', api['command'])
            self.assertIn('--enable-admission-plugins=NodeRestriction,ImagePolicyWebhook', api['command'])
            self.assertEqual(result['spec']['containers'][1]['command'], ['unchanged'])
            self.assertEqual(len(api['volumeMounts']), 2)
            self.assertEqual(len(result['spec']['volumes']), 2)

if __name__ == '__main__':
    unittest.main()
