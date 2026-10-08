#!/usr/bin/env bash
set -eu
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if test -f "$here/assets/solution2.sh"; then exec bash "$here/assets/solution2.sh"; fi
asset_dir=/opt/book-labs/infra-02-cluster-upgrade
for attempt in $(seq 1 60); do
  if test -f "$asset_dir/solution2.sh" && test -f "$asset_dir/infra.sh"; then exec bash "$asset_dir/solution2.sh"; fi
  sleep 1
done
mkdir -p /tmp/book-labs/infra-02-cluster-upgrade
printf 'Required assets missing from %s\n' "$asset_dir" | tee /tmp/book-labs/infra-02-cluster-upgrade/error >&2
exit 1
