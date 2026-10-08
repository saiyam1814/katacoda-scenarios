#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-07-pod-lifecycle
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
bash "$(dirname -- "${BASH_SOURCE[0]}")/verify-step-01.sh"
bash "$(dirname -- "${BASH_SOURCE[0]}")/verify-step-02.sh"
bash "$(dirname -- "${BASH_SOURCE[0]}")/verify-step-03.sh"
bash "$(dirname -- "${BASH_SOURCE[0]}")/verify-step-04.sh"
bash "$(dirname -- "${BASH_SOURCE[0]}")/verify-step-05.sh"
