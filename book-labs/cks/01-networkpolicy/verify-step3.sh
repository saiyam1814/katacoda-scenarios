#!/usr/bin/env bash
set -Eeuo pipefail
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if test -f "$here/assets/verify-step3.sh"; then exec bash "$here/assets/verify-step3.sh" "$@"; fi
exec bash /opt/book-labs/cks-01-networkpolicy/verify-step3.sh "$@"
