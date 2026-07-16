#!/bin/bash
C=$(kubectl get composition xwebapp-kubernetes -o json 2>/dev/null) || exit 1

python3 - "$C" <<'PYEOF' || exit 1
import json, sys
c = json.loads(sys.argv[1])
res = {r["name"]: r for r in c["spec"]["resources"]}
dep = res.get("app-deployment")
assert dep, "app-deployment resource missing"
patches = dep.get("patches", [])
pairs = {(p.get("fromFieldPath"), p.get("toFieldPath")) for p in patches
         if p.get("type", "FromCompositeFieldPath") == "FromCompositeFieldPath"}
need = {
    ("spec.appName", "spec.forProvider.manifest.metadata.name"),
    ("spec.appName", "spec.forProvider.manifest.spec.template.metadata.labels.app"),
    ("spec.appName", "spec.forProvider.manifest.spec.selector.matchLabels.app"),
    ("spec.desiredReplicas", "spec.forProvider.manifest.spec.replicas"),
    ("spec.containerImage", "spec.forProvider.manifest.spec.template.spec.containers[0].image"),
}
missing = need - pairs
assert not missing, f"missing patches: {missing}"
PYEOF

exit 0
