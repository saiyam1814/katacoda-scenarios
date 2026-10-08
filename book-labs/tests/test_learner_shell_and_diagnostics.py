"""Hosted-UI regressions: foreground scripts must preserve the learner shell."""
import os
import json
import pathlib
import subprocess
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]


class LearnerShellTests(unittest.TestCase):
    def test_every_foreground_script_preserves_shell_and_flags(self):
        paths = sorted(ROOT.glob('*/*/wait.sh'))
        self.assertTrue(paths, 'No foreground scripts were tested')
        # The fake seq/sleep make the timeout branch immediate without changing
        # the script. Source it as Killercoda injects it into the learner shell.
        runner = r'''
if [[ "$1" == strict ]]; then set -eu; else set +eu; fi
before=$-
seq() { printf '1\n'; }
sleep() { :; }
source "$2"
after=$-
[[ "$before" == "$after" ]] || { printf 'SHELL_FLAGS_CHANGED\n'; exit 9; }
printf 'LEARNER_SHELL_CONTINUES\n'
'''
        for path in paths:
            definition = json.loads((path.parent / 'index.json').read_text())
            lab_id = pathlib.PurePosixPath(definition['details']['assets']['host01'][0]['target']).name
            for state in ('ready', 'error', 'timeout'):
                for flags in ('plain', 'strict'):
                    with self.subTest(lab=lab_id, state=state, flags=flags), tempfile.TemporaryDirectory(prefix='book-wait-test-') as temp:
                        state_dir = pathlib.Path(temp) / lab_id
                        state_dir.mkdir()
                        if state == 'ready':
                            (state_dir / 'ready').touch()
                        elif state == 'error':
                            (state_dir / 'error').write_text('Setup failed for this test\n')
                        env = os.environ.copy()
                        env['BOOK_LAB_STATE_ROOT'] = temp
                        result = subprocess.run(['bash', '-c', runner, 'bash', flags, str(path)], env=env, capture_output=True, text=True, timeout=4)
                        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                        self.assertIn('LEARNER_SHELL_CONTINUES', result.stdout)
                        if state == 'ready':
                            self.assertIn('Ready.', result.stdout)
                        elif state == 'error':
                            self.assertIn('Setup failed for this test', result.stdout + result.stderr)
                        else:
                            self.assertRegex(result.stdout + result.stderr, r'Setup (?:timed out|incomplete|exceeded)')
                            self.assertIn('setup.log', result.stdout + result.stderr)


class JsonDiagnosticTests(unittest.TestCase):
    def check(self, data, expression):
        with tempfile.TemporaryDirectory(prefix='book-json-test-') as temp:
            env = os.environ.copy()
            env.update(LAB_ID='json-test', BOOK_LAB_STATE_ROOT=temp, BOOK_LAB_WORK_ROOT=temp)
            return subprocess.run(
                ['bash', '-c', 'source "$1"; json_assert "$2" "Expected a Ready resource"', 'bash', str(ROOT / 'cka/01-rbac/assets/lib.sh'), expression],
                input=data, text=True, capture_output=True, env=env, timeout=4,
            )

    def assert_concise_failure(self, result, detail):
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('FAIL: Expected a Ready resource' + detail, result.stderr)
        self.assertNotIn('Traceback', result.stderr)
        self.assertEqual(len(result.stderr.splitlines()), 1)

    def test_true_condition_passes(self):
        result = self.check('{"ready":true}', 'd["ready"] is True')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_false_condition_has_no_traceback(self):
        self.assert_concise_failure(self.check('{"ready":false}', 'd["ready"] is True'), '')

    def test_missing_json_has_no_traceback(self):
        self.assert_concise_failure(self.check('', 'd["ready"] is True'), ' (missing or invalid JSON input)')

    def test_malformed_json_has_no_traceback(self):
        self.assert_concise_failure(self.check('not JSON', 'd["ready"] is True'), ' (missing or invalid JSON input)')

    def test_missing_resource_fields_have_no_traceback(self):
        self.assert_concise_failure(self.check('{}', 'd["ready"] is True'), ' (missing or unexpected resource fields)')


if __name__ == '__main__':
    unittest.main()
