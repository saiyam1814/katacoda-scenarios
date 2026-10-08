#!/usr/bin/env bash
set -eu
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if test -f "$here/assets/verify-step-03.sh"; then exec bash "$here/assets/verify-step-03.sh"; fi
asset_dir=/opt/book-labs/cka-06-rollout-recovery
for attempt in $(seq 1 60); do
 if test -f "$asset_dir/verify-step-03.sh" && test -f "$asset_dir/lib.sh"; then exec bash "$asset_dir/verify-step-03.sh"; fi
 sleep 1
done
mkdir -p "${BOOK_LAB_STATE_ROOT:-/tmp/book-labs}/cka-06-rollout-recovery"
printf 'Required assets not delivered: %s\n' "$asset_dir" | tee "${BOOK_LAB_STATE_ROOT:-/tmp/book-labs}/cka-06-rollout-recovery/error" >&2
exit 1
