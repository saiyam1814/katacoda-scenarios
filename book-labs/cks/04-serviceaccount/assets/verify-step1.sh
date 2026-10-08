#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-04-serviceaccount
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
bash "$(dirname "$0")/base-verify.sh"
pass "Step 1: Remove excess access and token mounts"
