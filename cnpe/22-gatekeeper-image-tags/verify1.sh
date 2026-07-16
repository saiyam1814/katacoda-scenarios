#!/bin/bash
C=$(kubectl get forbidfloatingtag forbid-floating-tags -o json 2>/dev/null) || exit 1

python3 - "$C" <<'PYEOF' || exit 1
import json, sys
c = json.loads(sys.argv[1])
kinds = c["spec"]["match"]["kinds"]
flat = set()
for k in kinds:
    for g in k.get("apiGroups", []):
        for kk in k.get("kinds", []):
            flat.add((g, kk))
need = {
    ("apps", "Deployment"), ("apps", "DaemonSet"), ("apps", "StatefulSet"), ("apps", "ReplicaSet"),
    ("batch", "Job"), ("batch", "CronJob"),
    ("", "Pod"),
}
missing = need - flat
assert not missing, f"missing kinds: {missing}"
PYEOF
exit 0
