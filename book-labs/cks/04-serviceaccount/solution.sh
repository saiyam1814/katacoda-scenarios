#!/usr/bin/env bash
set -Eeuo pipefail
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if test -f "$here/assets/solution.sh"; then exec bash "$here/assets/solution.sh" "$@"; fi
exec bash /opt/book-labs/cks-04-serviceaccount/solution.sh "$@"
