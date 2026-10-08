"""Regression tests for bounded startup and current-Pod scheduling evidence.
All kubectl calls use a temporary fake executable; no cluster is contacted.
"""
import json
import os
import pathlib
import subprocess
import tempfile
import time
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
FAKE_KUBECTL = r'''#!/usr/bin/env python3
import json, os, pathlib, sys, time
args = sys.argv[1:]
with open(os.environ["FAKE_KUBECTL_LOG"], "a") as log:
    log.write(json.dumps(args) + "\n")
mode = os.environ["FAKE_KUBECTL_MODE"]
if mode == "hang":
    time.sleep(15)
    sys.exit(1)
if mode == "ready":
    print("ok")
    sys.exit(0)
if "wait" in args:
    print("pod/reporter condition met")
elif "get" in args and "events" in args:
    selector = args[args.index("--field-selector") + 1]
    wanted = dict(field.split("=", 1) for field in selector.split(","))
    event = {"involvedObject": {"name": "reporter", "uid": os.environ["FAKE_EVENT_UID"]}, "reason": "Scheduled"}
    matches = all(
        (event["involvedObject"].get(key.split(".", 1)[1]) if key.startswith("involvedObject.") else event.get(key)) == value
        for key, value in wanted.items()
    )
    print(json.dumps({"items": [event] if matches else []}))
elif "get" in args and "node" in args:
    print(json.dumps({"metadata": {"labels": {"book-labs.example/disk": "ssd"}}}))
elif "get" in args and "pod" in args:
    output = args[args.index("-o") + 1]
    if output == "jsonpath={.metadata.uid}":
        print("current-pod-uid", end="")
    elif output == "jsonpath={.spec.nodeName}":
        print("node1", end="")
    elif output == "json":
        print(json.dumps({"metadata": {"uid": "current-pod-uid"}, "status": {"phase": "Running", "conditions": [{"type": "Ready", "status": "True"}]}, "spec": {
            "nodeSelector": {"book-labs.example/disk": "ssd"},
            "nodeName": "node1", "containers": [{"image": "busybox:1.37.0", "command": ["sh", "-c", "sleep 3600"]}]
        }}))
    else:
        raise AssertionError(args)
else:
    raise AssertionError(args)
'''


class LabRegressionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="book-lab-regression-")
        self.addCleanup(self.temp.cleanup)
        self.path = pathlib.Path(self.temp.name)
        bindir = self.path / "bin"
        bindir.mkdir()
        fake = bindir / "kubectl"
        fake.write_text(FAKE_KUBECTL)
        fake.chmod(0o755)
        self.env = os.environ.copy()
        self.env.update({
            "PATH": str(bindir) + os.pathsep + self.env["PATH"],
            "BOOK_LAB_STATE_ROOT": str(self.path / "state"),
            "BOOK_LAB_WORK_ROOT": str(self.path / "work"),
            "FAKE_KUBECTL_LOG": str(self.path / "calls.jsonl"),
            "BOOK_LAB_API_TIMEOUT_SECONDS": "1",
        })

    def preflight(self, mode):
        self.env["FAKE_KUBECTL_MODE"] = mode
        self.env["LAB_ID"] = "preflight-test"
        lib = ROOT / "cka/01-rbac/assets/lib.sh"
        return subprocess.run(
            ["bash", "-c", 'source "$1"; setup_begin; setup_done', "bash", str(lib)],
            env=self.env, capture_output=True, text=True, timeout=6,
        )

    def test_hanging_kubectl_respects_budget_and_marks_error(self):
        start = time.monotonic()
        result = self.preflight("hang")
        self.assertNotEqual(result.returncode, 0)
        self.assertLess(time.monotonic() - start, 5)
        state = self.path / "state/preflight-test"
        self.assertIn("API readiness timed out", (state / "error").read_text())
        self.assertFalse((state / "ready").exists())
        calls = [json.loads(line) for line in (self.path / "calls.jsonl").read_text().splitlines()]
        self.assertEqual(calls, [["--request-timeout=5s", "get", "--raw=/readyz"]])

    def test_ready_api_completes_and_marks_ready(self):
        result = self.preflight("ready")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        state = self.path / "state/preflight-test"
        self.assertTrue((state / "ready").exists())
        self.assertFalse((state / "error").exists())

    def verify_schedule(self, event_uid):
        self.env.update(FAKE_KUBECTL_MODE="schedule", FAKE_EVENT_UID=event_uid)
        state = self.path / "state/cka-05-scheduling"
        state.mkdir(parents=True, exist_ok=True)
        (state / "ready").touch()
        return subprocess.run(
            ["bash", str(ROOT / "cka/05-scheduling/verify-step-01.sh")],
            env=self.env, capture_output=True, text=True, timeout=6,
        )

    def test_previous_pod_scheduled_event_does_not_pass_current_pod(self):
        result = self.verify_schedule("deleted-pod-uid")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Current Pod must have a Scheduled event", result.stderr)

    def test_current_pod_scheduled_event_passes(self):
        result = self.verify_schedule("current-pod-uid")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Step 1: Repair a node selector", result.stdout)


if __name__ == "__main__":
    unittest.main()
