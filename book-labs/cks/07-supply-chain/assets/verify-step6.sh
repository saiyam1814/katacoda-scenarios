#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-07-supply-chain
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
test ! -e "$WORK_DIR/release/cosign.key"
cosign verify-blob --offline --key "$WORK_DIR/release/cosign.pub" --bundle "$WORK_DIR/release/manifest.bundle.json" "$WORK_DIR/release/manifest.json"
if cosign verify-blob --offline --key "$WORK_DIR/release/cosign.pub" --bundle "$WORK_DIR/release/manifest.bundle.json" "$WORK_DIR/release/changed.json" >/dev/null 2>&1; then fail 'Changed content unexpectedly verifies'; fi
python3 - "$WORK_DIR/release/manifest.bundle.json" <<'PYVERIFY'
import json,sys
b=json.load(open(sys.argv[1]));assert b.get('verificationMaterial',{}).get('tlogEntries'), 'Retain transparency evidence in the bundle'
PYVERIFY
pass "Step 6: Sign the release and reject changed content"
