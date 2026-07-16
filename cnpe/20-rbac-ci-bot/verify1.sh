#!/bin/bash
kubectl -n build-room get sa ci-bot >/dev/null 2>&1 || exit 1
R=$(kubectl -n build-room get role ci-bot -o json 2>/dev/null) || exit 1
kubectl -n build-room get rolebinding ci-bot -o json > /tmp/.rb.json 2>/dev/null || exit 1

python3 - "$R" <<'PYEOF' || exit 1
import json, sys
r = json.loads(sys.argv[1])
want = {"get", "list", "watch", "create", "update", "patch"}
dep_ok = cm_ok = False
for rule in r["rules"]:
    groups = rule.get("apiGroups", [])
    res = rule.get("resources", [])
    verbs = set(rule.get("verbs", []))
    if "deployments" in res and "apps" in groups:
        assert verbs == want, f"deployment verbs wrong: {verbs}"
        dep_ok = True
    if "configmaps" in res and ("" in groups):
        assert verbs == want, f"configmap verbs wrong: {verbs}"
        cm_ok = True
assert dep_ok and cm_ok

rb = json.load(open("/tmp/.rb.json"))
assert rb["roleRef"]["kind"] == "Role" and rb["roleRef"]["name"] == "ci-bot"
subs = rb.get("subjects", [])
assert any(s.get("kind") == "ServiceAccount" and s.get("name") == "ci-bot"
           and s.get("namespace") == "build-room" for s in subs)
PYEOF
exit 0
