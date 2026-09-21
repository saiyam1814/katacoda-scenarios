#!/bin/bash
set -euo pipefail
kubectl -n workflows get workflows -o json | python3 -c '
import json,sys
expected_deploy={"image":"alpine/k8s:1.35.0","command":["kubectl"],"args":["-n","stage-coral","rollout","restart","deploy/checkout-api"]}
expected_test={"image":"busybox:1.36","command":["sh","-c"],"args":["echo "+chr(34)+"smoke tests passed"+chr(34)]}
for w in json.load(sys.stdin)["items"]:
    try:
        assert w["metadata"]["name"].startswith("release-checker-")
        assert w["status"]["phase"]=="Succeeded"
        t={t["name"]:t for t in w["spec"]["templates"]}
        stages=t[w["spec"]["entrypoint"]]["steps"]
        assert [[s["name"] for s in stage] for stage in stages]==[["deploy"],["ready-check"],["test"]]
        assert [stage[0]["template"] for stage in stages]==["deploy","wait-ready","test"]
        c=t["wait-ready"]["container"]
        assert c["image"]=="alpine/k8s:1.35.0" and c["command"]==["kubectl"]
        assert c["args"]==["rollout","status","deploy/checkout-api","-n","stage-coral","--timeout=90s"]
        assert not any(t[n].get("continueOn") for n in t)
        assert not any(step.get("continueOn") or step.get("when") for stage in stages for step in stage)
        for name,expected in [("deploy",expected_deploy),("test",expected_test)]:
            assert all(t[name]["container"].get(k)==v for k,v in expected.items())
        nodes={n["displayName"]:n for n in w["status"]["nodes"].values() if n.get("type")=="Pod"}
        assert all(nodes[n]["phase"]=="Succeeded" for n in ["deploy","ready-check","test"])
        assert nodes["deploy"]["finishedAt"] <= nodes["ready-check"]["startedAt"]
        assert nodes["ready-check"]["finishedAt"] <= nodes["test"]["startedAt"]
        sys.exit(0)
    except (AssertionError,KeyError):
        continue
sys.exit(1)
'
exit 0
