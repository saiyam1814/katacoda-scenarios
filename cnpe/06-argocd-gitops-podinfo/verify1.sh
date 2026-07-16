#!/bin/bash
APP=$(kubectl -n argocd get application podinfo-ui -o json 2>/dev/null) || exit 1

python3 - "$APP" <<'PYEOF' || exit 1
import json, sys
app = json.loads(sys.argv[1])
spec = app["spec"]
src = spec["source"]
assert src["repoURL"].rstrip("/").replace(".git","") == "https://github.com/stefanprodan/podinfo"
assert src["path"] == "charts/podinfo"
assert src["targetRevision"] in ("master", "HEAD")
vals = src.get("helm", {}).get("values", "") or json.dumps(src.get("helm", {}).get("valuesObject", {}))
assert "replicaCount: 2" in vals or '"replicaCount": 2' in vals
assert "ClusterIP" in vals
assert "#336699" in vals
dst = spec["destination"]
assert dst.get("namespace") == "apps-ui"
sp = spec.get("syncPolicy", {})
assert "automated" in sp
opts = sp.get("syncOptions", [])
assert any("CreateNamespace=true" in o for o in opts)
PYEOF

exit 0
