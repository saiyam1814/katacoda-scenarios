route_current() {
 local route
 if ! route=$(kubectl -n book-cka-routing get httproute shop -o json); then
  printf '%s\n' 'FAIL: Create HTTPRoute shop in book-cka-routing before checking its current status' >&2
  return 1
 fi
 printf '%s\n' "$route" | python3 -c 'import json,sys; d=json.load(sys.stdin); g=d["metadata"]["generation"]; parents=[p for p in d.get("status",{}).get("parents",[]) if p["parentRef"]["name"]=="public-web" and p["parentRef"].get("sectionName")=="http" and p["controllerName"]=="traefik.io/gateway-controller"]; assert any(all(any(c["type"]==t and c["status"]=="True" and c.get("observedGeneration")==g for c in p["conditions"]) for t in ["Accepted","ResolvedRefs"]) for p in parents), "Current parent status is not accepted and resolved"'
}
routing_ip() { kubectl -n book-cka-routing get gateway public-web -o jsonpath='{.status.addresses[0].value}'; }
gateway_ok() { local ip; ip=$(routing_ip); test -n "$ip" && kubectl -n book-cka-routing exec client -- curl -fsS --max-time 4 --resolve "shop.cka.lab:80:$ip" http://shop.cka.lab/ | grep -q 'Welcome to nginx'; }
ingress_ok() { local ip; ip=$(kubectl -n book-cka-routing get ingress web -o jsonpath='{.status.loadBalancer.ingress[0].ip}'); test -n "$ip" && kubectl -n book-cka-routing exec client -- curl -fsS --max-time 4 --cacert /trust/ca.crt --resolve "web.cka.lab:443:$ip" https://web.cka.lab/ | grep -q 'Welcome to nginx'; }
