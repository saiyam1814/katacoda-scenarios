#!/usr/bin/env bash
LAB_ID=infra-03-etcd-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
bash "$ASSET_DIR/verify1.sh"
if test -f "$STATE_DIR/deletion-observed"; then printf 'Deletion was already injected; continue recovery.\n'; exit 0; fi
k -n cka11 delete configmap before-backup
k -n cka11 create configmap after-backup --from-literal=message=must-disappear
if k -n cka11 get configmap before-backup >/dev/null 2>&1; then fail 'Original ConfigMap still exists'; fi
touch "$STATE_DIR/deletion-observed"
printf 'Original object is absent; post-backup object exists. Recover from the snapshot.\n'
