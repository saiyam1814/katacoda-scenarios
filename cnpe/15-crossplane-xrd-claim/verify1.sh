#!/bin/bash
set -euo pipefail
kubectl get xrd bucketapps.platform.example.io -o json | python3 -c '
import json,sys
x=json.load(sys.stdin); s=x["spec"]
assert s["scope"]=="Namespaced" and not s.get("claimNames")
assert s["group"]=="platform.example.io" and s["names"]["kind"]=="BucketApp"
v=next(v for v in s["versions"] if v["name"]=="v1alpha1")
assert v["served"] and v["referenceable"]
schema=v["schema"]["openAPIV3Schema"]
assert "spec" in schema["required"]
sp=schema["properties"]["spec"]
assert {"region","size"} <= set(sp["required"])
assert all(sp["properties"][p]["type"]=="string" for p in ["region","size"])
assert any(c["type"]=="Established" and c["status"]=="True" for c in x["status"]["conditions"])
'
[ "$(kubectl get crd bucketapps.platform.example.io -o jsonpath='{.spec.scope}')" = Namespaced ]
exit 0
