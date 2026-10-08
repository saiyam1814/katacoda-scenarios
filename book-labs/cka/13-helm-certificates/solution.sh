#!/usr/bin/env bash
set -eu
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if test -f "$here/assets/solution.sh"; then exec bash "$here/assets/solution.sh"; fi
asset_dir=/opt/book-labs/cka-13-helm-certificates
for attempt in $(seq 1 60); do
 if test -f "$asset_dir/solution.sh" && test -f "$asset_dir/lib.sh"; then exec bash "$asset_dir/solution.sh"; fi
 sleep 1
done
mkdir -p "${BOOK_LAB_STATE_ROOT:-/tmp/book-labs}/cka-13-helm-certificates"
printf 'Required assets not delivered: %s\n' "$asset_dir" | tee "${BOOK_LAB_STATE_ROOT:-/tmp/book-labs}/cka-13-helm-certificates/error" >&2
exit 1
