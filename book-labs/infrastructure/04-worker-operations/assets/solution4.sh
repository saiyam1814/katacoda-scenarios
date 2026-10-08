#!/usr/bin/env bash
LAB_ID=infra-04-worker-operations
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
if ! test -f "$STATE_DIR/insecure-kubelet-baseline"; then bash "$ASSET_DIR/prepare4.sh"; fi
remote python3 /tmp/book-patch-kubelet.py secure
remote systemctl restart kubelet
kubectl wait --for=condition=Ready node/node01 --timeout=180s
for n in $(seq 1 45); do
 code=$(remote curl -ksS --max-time 2 -o /dev/null -w '%{http_code}' https://127.0.0.1:10250/pods) || code=000
 if [[ "$code" == 401 ]]; then break; fi
 sleep 2
done
bash "$ASSET_DIR/verify4.sh"
