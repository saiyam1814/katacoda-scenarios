#!/bin/bash
kubectl -n ci-otter get pipelinerun -o json > /tmp/.prs.json 2>/dev/null || exit 1

python3 <<'PYEOF' || exit 1
import json
prs = json.load(open("/tmp/.prs.json"))["items"]
failed_bad = ok_good = False
for pr in prs:
    params = {p["name"]: p.get("value") for p in pr.get("spec", {}).get("params", [])}
    img = params.get("image", "")
    succeeded = None
    for c in pr.get("status", {}).get("conditions", []):
        if c.get("type") == "Succeeded":
            succeeded = (c.get("status") == "True")
    if img == "nginx:1.16" and succeeded is False:
        failed_bad = True
    if img == "gcr.io/distroless/static:nonroot" and succeeded is True:
        ok_good = True
assert failed_bad, "no failed run for the vulnerable image"
assert ok_good, "no successful run for the clean image"
PYEOF

# the good image got deployed, and it is the distroless one
IMG=$(kubectl -n ci-otter get deploy shipped -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
[ "$IMG" = "gcr.io/distroless/static:nonroot" ] || exit 1
exit 0
