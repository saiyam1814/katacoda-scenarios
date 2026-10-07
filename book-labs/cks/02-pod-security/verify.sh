#!/usr/bin/env bash
set -eu
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if test -f "$here/assets/verify.sh"; then
  exec bash "$here/assets/verify.sh"
fi
asset_dir=/opt/book-labs/cks-02-pod-security
for attempt in $(seq 1 60); do
  if test -f "$asset_dir/verify.sh" && test -f "$asset_dir/lib.sh"; then exec bash "$asset_dir/verify.sh"; fi
  sleep 1
done
mkdir -p "${BOOK_LAB_STATE_ROOT:-/tmp/book-labs}/cks-02-pod-security"
printf 'Required lab assets were not delivered to %s\n' "$asset_dir" | tee "${BOOK_LAB_STATE_ROOT:-/tmp/book-labs}/cks-02-pod-security/error" >&2
exit 1
