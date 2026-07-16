#!/bin/bash
P=$(kubectl get clusterpolicy supply-chain-signoff -o json 2>/dev/null) || exit 1

python3 - "$P" <<'PYEOF' || exit 1
import json, sys
p = json.loads(sys.argv[1])
spec = p["spec"]
assert str(spec.get("validationFailureAction", "")).lower() == "enforce"
rules = spec["rules"]
vi_rules = [r for r in rules if "verifyImages" in r]
assert vi_rules, "no verifyImages rule"
r = vi_rules[0]
kinds = json.dumps(r.get("match", {}))
assert "Pod" in kinds
vi = r["verifyImages"][0]
refs = vi.get("imageReferences", [])
assert "*" in refs
body = json.dumps(vi)
assert "https://accounts.google.com" in body
assert "keyless@distroless.iam.gserviceaccount.com" in body
assert "rekor.sigstore.dev" in body
PYEOF

# Policy ready
READY=$(kubectl get clusterpolicy supply-chain-signoff -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
[ "$READY" = "True" ] || exit 1
exit 0
