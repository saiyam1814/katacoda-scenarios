#!/usr/bin/env bash
set -Eeuo pipefail
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if test -f "$here/assets/verify-step2.sh"; then exec bash "$here/assets/verify-step2.sh" "$@"; fi
exec bash /opt/book-labs/cks-09-ingress-mtls/verify-step2.sh "$@"
