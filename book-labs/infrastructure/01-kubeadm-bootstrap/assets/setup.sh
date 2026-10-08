#!/usr/bin/env bash
LAB_ID=infra-01-kubeadm-bootstrap
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"
setup_begin

remote true
# These are the two disposable VMs in this scenario, never an external context.
timeout 120 ssh -o BatchMode=yes -o ConnectTimeout=5 node01 bash -s -- reset < "$ASSET_DIR/node-packages.sh"
timeout 120 bash "$ASSET_DIR/node-packages.sh" reset

printf "Reset complete. Build the cluster using the task.\n"
setup_done
