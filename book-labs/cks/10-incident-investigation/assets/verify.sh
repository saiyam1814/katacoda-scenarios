#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-10-incident-investigation
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
bash "$(dirname -- "${BASH_SOURCE[0]}")/verify-step1.sh"
bash "$(dirname -- "${BASH_SOURCE[0]}")/verify-step2.sh"
