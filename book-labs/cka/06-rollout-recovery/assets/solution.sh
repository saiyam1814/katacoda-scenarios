#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-06-rollout-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
bash "$(dirname -- "${BASH_SOURCE[0]}")/solution-step-01.sh"
bash "$(dirname -- "${BASH_SOURCE[0]}")/solution-step-02.sh"
bash "$(dirname -- "${BASH_SOURCE[0]}")/solution-step-03.sh"
