#!/usr/bin/env bash
LAB_ID=infra-04-worker-operations
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
bash "$ASSET_DIR/verify3.sh"
# The fixture is intentionally insecure only inside this disposable worker VM.
scp -q -o BatchMode=yes -o ConnectTimeout=5 "$ASSET_DIR/patch-kubelet.py" node01:/tmp/book-patch-kubelet.py
remote bash -c "'python3 -c \"import yaml\" || (apt-get update -qq && apt-get install -y -qq python3-yaml)'"
remote cp /var/lib/kubelet/config.yaml /root/cks24-kubelet-before.yaml
remote python3 /tmp/book-patch-kubelet.py insecure
remote systemctl restart kubelet
for n in $(seq 1 45); do
 code=$(remote curl -ksS --max-time 2 -o /dev/null -w '%{http_code}' https://127.0.0.1:10250/pods) || code=000
 if [[ "$code" == 200 ]]; then break; fi
 sleep 2
done
[[ "$code" == 200 ]] || fail 'Insecure anonymous kubelet baseline was not observed'
remote curl -fsS --max-time 2 http://127.0.0.1:10255/pods >/dev/null
printf 'Observed anonymous HTTP 200 and an open read-only port before repair.\n' > "$STATE_DIR/insecure-kubelet-baseline"
printf 'The deliberate worker security fixture is ready. Now harden it.\n'
