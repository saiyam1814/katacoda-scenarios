#!/usr/bin/env bash
set -eu
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if test -f "$here/assets/solution1.sh"; then exec bash "$here/assets/solution1.sh"; fi
asset_dir=/opt/book-labs/infra-06-api-repair
for attempt in $(seq 1 60); do
  if test -f "$asset_dir/solution1.sh" && test -f "$asset_dir/infra.sh"; then exec bash "$asset_dir/solution1.sh"; fi
  sleep 1
done
mkdir -p /tmp/book-labs/infra-06-api-repair
printf 'Required assets missing from %s\n' "$asset_dir" | tee /tmp/book-labs/infra-06-api-repair/error >&2
exit 1
