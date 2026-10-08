#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-01-networkpolicy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
curl --fail --max-time 2 http://169.254.169.254/ | grep -q synthetic-metadata
kubectl -n book-cks-metadata exec client -- wget -T 2 -qO- http://web/ >/dev/null
if kubectl -n book-cks-metadata exec client -- wget -T 2 -qO- http://169.254.169.254/ >/dev/null 2>&1; then fail 'Client can still reach metadata'; fi
kubectl -n book-cks-metadata get pod client -o json | json_assert 'd["status"]["phase"]=="Running"' 'Keep the client running'
pass "Step 3: Block metadata and preserve application access"
