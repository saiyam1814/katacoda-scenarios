#!/bin/bash
# policy objects wired correctly
M=$(kubectl -n payments get meshtlsauthentication storefront-only -o json 2>/dev/null) || exit 1
A=$(kubectl -n payments get authorizationpolicy.policy.linkerd.io checkout-allow-storefront -o json 2>/dev/null) || exit 1

python3 - "$M" "$A" <<'PYEOF' || exit 1
import json, sys
m, a = json.loads(sys.argv[1]), json.loads(sys.argv[2])
ids = m["spec"]["identities"]
assert "storefront.web.serviceaccount.identity.linkerd.cluster.local" in ids, ids
t = a["spec"]["targetRef"]
assert t["kind"] == "Server" and t["name"] == "checkout"
refs = a["spec"]["requiredAuthenticationRefs"]
assert any(r["kind"] == "MeshTLSAuthentication" and r["name"] == "storefront-only" for r in refs)
PYEOF

# live behavior: storefront allowed
OUT=$(kubectl -n web exec storefront -c curl -- curl -s --max-time 5 http://checkout.payments.svc:8080/hostname 2>/dev/null)
echo "$OUT" | grep -q "checkout" || exit 1

# reporting denied (403 from the proxy, or no payload)
OUT2=$(kubectl -n batch exec reporting -c curl -- curl -s --max-time 5 http://checkout.payments.svc:8080/hostname 2>/dev/null)
echo "$OUT2" | grep -q "checkout" && exit 1

exit 0
