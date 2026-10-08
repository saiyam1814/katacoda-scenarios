#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-03-runtime-hardening
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
bash "$(dirname -- "${BASH_SOURCE[0]}")/verify-step1.sh"
bash "$(dirname -- "${BASH_SOURCE[0]}")/verify-step2.sh"
bash "$(dirname -- "${BASH_SOURCE[0]}")/verify-step3.sh"
