#!/bin/bash
X=$(kubectl get xrd xbucketapps.platform.example.io -o json 2>/dev/null) || exit 1

python3 - "$X" <<'PYEOF' || exit 1
import json, sys
x = json.loads(sys.argv[1])
spec = x["spec"]
assert spec["group"] == "platform.example.io"
assert spec["names"]["kind"] == "XBucketApp"
assert spec.get("claimNames", {}).get("kind") == "BucketApp"
v = [i for i in spec["versions"] if i["name"] == "v1alpha1"]
assert v and v[0]["served"] and v[0]["referenceable"]
s = v[0]["schema"]["openAPIV3Schema"]["properties"]["spec"]
assert set(s.get("required", [])) >= {"region", "size"}
assert s["properties"]["region"]["type"] == "string"
assert s["properties"]["size"]["type"] == "string"

# both conditions
conds = {c["type"]: c["status"] for c in x.get("status", {}).get("conditions", [])}
assert conds.get("Established") == "True"
assert conds.get("Offered") == "True"
PYEOF

exit 0
