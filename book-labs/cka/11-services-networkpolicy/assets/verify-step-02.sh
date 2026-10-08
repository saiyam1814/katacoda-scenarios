#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-11-services-networkpolicy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
source "$(dirname -- "${BASH_SOURCE[0]}")/network.sh"

kubectl -n book-cka-policy get networkpolicy frontend-only -o json | json_assert 'd["spec"]["podSelector"]=={} and d["spec"]["ingress"][0]["from"][0].get("namespaceSelector",{}).get("matchLabels")=={"book-labs.example/team":"frontend"} and d["spec"]["ingress"][0]["from"][0].get("podSelector",{}).get("matchLabels")=={"role":"allowed"}' 'Put both selectors in the same peer so they are ANDed'
kubectl -n book-cka-policy get networkpolicy default-deny -o json | json_assert 'd["spec"]["podSelector"]=={} and not d["spec"].get("ingress") and "Ingress" in d["spec"]["policyTypes"]' 'Default deny must select all Pods in the namespace'
IP=$(network_target)
http_ok book-cka-frontend trusted "http://$IP" || fail 'Required frontend traffic must work'
blocked book-cka-frontend wrong-label "http://$IP" & a=$!
blocked book-cka-other trusted "http://$IP" & b=$!
blocked book-cka-frontend trusted "http://$IP:8080" & c=$!
wait "$a" || fail 'Wrong Pod label was not blocked by timeout'
wait "$b" || fail 'Wrong namespace was not blocked by timeout'
wait "$c" || fail 'Wrong listening port was not blocked by timeout'
pass "Step 2: Allow only the required namespace, Pod label and port"
