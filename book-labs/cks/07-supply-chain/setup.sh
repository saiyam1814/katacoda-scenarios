#!/usr/bin/env bash
set -Eeuo pipefail
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if test -f "$here/assets/setup.sh"; then exec bash "$here/assets/setup.sh" "$@"; fi
exec bash /opt/book-labs/cks-07-supply-chain/setup.sh "$@"
