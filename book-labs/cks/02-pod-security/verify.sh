#!/usr/bin/env bash
set -Eeuo pipefail
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if test -f "$here/assets/verify.sh"; then exec bash "$here/assets/verify.sh" "$@"; fi
exec bash /opt/book-labs/cks-02-pod-security/verify.sh "$@"
