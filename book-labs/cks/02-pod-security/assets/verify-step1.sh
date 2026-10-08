#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-02-pod-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
bash "$(dirname "$0")/base-verify.sh"
pass "Step 1: Enforce restricted Pod Security Admission"
