#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-11-services-networkpolicy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-services get svc web -o json | json_assert 'd["spec"]["type"]=="ClusterIP" and d["spec"]["ports"][0]["port"]==80 and d["spec"]["ports"][0]["targetPort"]=="http"' 'Require the ClusterIP Service'
kubectl -n book-cka-services get svc node-web -o json | json_assert 'd["spec"]["type"]=="NodePort" and d["spec"]["ports"][0]["nodePort"]==31815' 'Require the requested NodePort'
kubectl -n book-cka-services get svc public-web -o json | json_assert 'd["spec"]["type"]=="LoadBalancer"' 'Create the LoadBalancer Service'
kubectl -n book-cka-services exec client -- wget -qO- -T 3 http://web | grep -q 'Welcome to nginx'
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
kubectl -n book-cka-services exec client -- wget -qO- -T 3 "http://$NODE_IP:31815" | grep -q 'Welcome to nginx'
kubectl -n book-cka-services exec client -- wget -qO- -T 3 http://web-alt:3231 | grep -q 'Welcome to nginx' || fail 'Alternate Service port3231 must reach port80'
test -s "$WORK_DIR/loadbalancer-status.txt" || fail 'Record the observed external load balancer status'
pass "Step 1: Create and test three Service types"
