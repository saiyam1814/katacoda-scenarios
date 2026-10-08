#!/usr/bin/env bash
LAB_ID=infra-03-etcd-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
test -s /var/backups/cka11.db || fail 'Snapshot /var/backups/cka11.db is missing'
"$WORK_DIR/bin/etcdutl" snapshot status /var/backups/cka11.db -w json | json_check 'd["revision"] > 0 and d["totalKey"] > 0 and d["totalSize"] > 0' 'Snapshot metadata is invalid'
pass 'Real etcd snapshot has a valid hash, revision and key count'
