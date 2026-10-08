#!/usr/bin/env bash
set -eu
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if test -f "$here/assets/verify1.sh"; then exec bash "$here/assets/verify1.sh"; fi
asset_dir=/opt/book-labs/infra-05-ha-control-plane
for attempt in $(seq 1 60); do
  if test -f "$asset_dir/verify1.sh" && test -f "$asset_dir/infra.sh"; then exec bash "$asset_dir/verify1.sh"; fi
  sleep 1
done
mkdir -p /tmp/book-labs/infra-05-ha-control-plane
printf 'Required assets missing from %s\n' "$asset_dir" | tee /tmp/book-labs/infra-05-ha-control-plane/error >&2
exit 1
