#!/usr/bin/env bash
set -Eeuo pipefail
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if test -f "$here/assets/verify-step1.sh"; then exec bash "$here/assets/verify-step1.sh" "$@"; fi
exec bash /opt/book-labs/cks-07-supply-chain/verify-step1.sh "$@"
