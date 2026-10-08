#!/usr/bin/env bash
LAB_ID=infra-04-worker-operations
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
test -s "$STATE_DIR/insecure-kubelet-baseline" || fail 'Prepare the insecure fixture before solving this step'
code=$(remote curl -ksS --max-time 2 -o /dev/null -w '%{http_code}' https://127.0.0.1:10250/pods)
[[ "$code" == 401 ]] || fail "Anonymous kubelet request should return 401; observed $code"
remote python3 - <<'EOF'
import pathlib,sys,yaml,socket
p=yaml.safe_load(pathlib.Path('/var/lib/kubelet/config.yaml').read_text())
if p['authentication']['anonymous']['enabled'] is not False or p['authentication']['webhook']['enabled'] is not True or p['authorization']['mode']!='Webhook' or p.get('readOnlyPort',0)!=0:sys.exit('FAIL: kubelet authentication/authorization settings are incomplete')
s=socket.socket();s.settimeout(1)
if s.connect_ex(('127.0.0.1',10255))==0:sys.exit('FAIL: kubelet read-only port is still listening')
EOF
# Anonymous401 does not prove authorization. A valid, unprivileged SA token
# must authenticate and receive403, catching an AlwaysAllow command-line override.
token=$(k -n cka23 create token default --duration=10m)
code=$(remote curl -ksS --max-time 2 -H "'Authorization: Bearer $token'" -o /dev/null -w '%{http_code}' https://127.0.0.1:10250/pods)
unset token
[[ "$code" == 403 ]] || fail "Unprivileged authenticated kubelet request should return403; observed $code"
k -n cka23 logs restored | grep -q kubelet-ok || fail 'Authenticated API-to-kubelet logs failed'
[[ "$(k -n cka23 exec restored -- printf authenticated-ok)" == authenticated-ok ]] || fail 'Authenticated exec failed'
server=$(k config view --minify -o jsonpath='{.clusters[0].cluster.server}')
code=$(curl --noproxy '*' --cacert /etc/kubernetes/pki/ca.crt --max-time 2 -o /dev/null -sS -w '%{http_code}' "$server/api/v1/secrets")
[[ "$code" == 401 || "$code" == 403 ]] || fail "Anonymous API request was not rejected with 401/403: $code"
pass 'Anonymous kubelet/API access denied, read-only port closed, authenticated logs and exec work'
