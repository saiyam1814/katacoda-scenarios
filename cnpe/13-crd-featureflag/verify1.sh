#!/bin/bash
CRD=$(kubectl get crd featureflags.toggle.acme.dev -o json 2>/dev/null) || exit 1

python3 - "$CRD" <<'PYEOF' || exit 1
import json, sys
crd = json.loads(sys.argv[1])
spec = crd["spec"]
assert spec["group"] == "toggle.acme.dev"
assert spec["scope"] == "Namespaced"
names = spec["names"]
assert names["kind"] == "FeatureFlag"
assert names["plural"] == "featureflags"
assert "ff" in names.get("shortNames", [])
v = [x for x in spec["versions"] if x["name"] == "v1beta1"]
assert v and v[0]["served"] and v[0]["storage"]
schema = v[0]["schema"]["openAPIV3Schema"]
s = schema["properties"]["spec"]
assert set(s.get("required", [])) == {"key", "enabled", "rolloutPercent"}
props = s["properties"]
assert props["key"]["type"] == "string"
assert props["enabled"]["type"] == "boolean"
rp = props["rolloutPercent"]
assert rp["type"] == "integer" and rp.get("minimum") == 0 and rp.get("maximum") == 100
PYEOF

# Established
kubectl wait --for=condition=established crd/featureflags.toggle.acme.dev --timeout=5s >/dev/null 2>&1 || exit 1
exit 0
