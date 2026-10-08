http_ok() { kubectl -n "$1" exec "$2" -- wget -qO- -T 3 "$3" | grep -q book-network; }
blocked() {
 local namespace=$1 client=$2 url=$3
 kubectl -n "$namespace" exec "$client" -- sh -c 'out=$(wget -O- -T 3 "$1" 2>&1); rc=$?; test "$rc" != 0 && echo "$out" | grep -Eq "timed out|timeout"' sh "$url"
}
network_target() { kubectl -n book-cka-policy get pod backend -o jsonpath='{.status.podIP}'; }
