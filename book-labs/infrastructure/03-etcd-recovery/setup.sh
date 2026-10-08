#!/usr/bin/env bash
set -eu
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if test -f "$here/assets/setup.sh"; then exec bash "$here/assets/setup.sh"; fi
asset_dir=/opt/book-labs/infra-03-etcd-recovery
for attempt in $(seq 1 60); do
  if test -f "$asset_dir/setup.sh" && test -f "$asset_dir/infra.sh"; then exec bash "$asset_dir/setup.sh"; fi
  sleep 1
done
mkdir -p /tmp/book-labs/infra-03-etcd-recovery
printf 'Required assets missing from %s\n' "$asset_dir" | tee /tmp/book-labs/infra-03-etcd-recovery/error >&2
exit 1
