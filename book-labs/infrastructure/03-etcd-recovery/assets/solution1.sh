#!/usr/bin/env bash
LAB_ID=infra-03-etcd-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
"$WORK_DIR/bin/etcdctl" --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key snapshot save /var/backups/cka11.db
"$WORK_DIR/bin/etcdutl" snapshot status /var/backups/cka11.db -w table
