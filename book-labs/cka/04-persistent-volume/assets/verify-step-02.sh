#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-04-persistent-volume
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
source "$(dirname -- "${BASH_SOURCE[0]}")/local-node.sh"

kubectl get pv book-cka-local-retained -o json | json_assert 'd["status"]["phase"]=="Released" and d["spec"]["persistentVolumeReclaimPolicy"]=="Retain" and d["spec"].get("local",{}).get("path")=="/var/book-labs/cka-local/retained"' 'The second PV must be Released, with its local data retained'
[[ $(kubectl get pv book-cka-local-retained -o jsonpath='{.spec.claimRef.uid}') == "$(cat "$WORK_DIR/deleted-claim-uid.txt")" ]] || fail 'Retain the deleted claim reference and save its UID'
[[ -z $(kubectl -n book-cka-storage get pvc retained --ignore-not-found -o name) ]] || fail 'Delete the retained claim'
node_exec cat /var/book-labs/cka-local/retained/retained.txt | grep -qx retained-after-claim-deletion || fail 'The written data must survive claim deletion'
pass "Step 2: Observe Retain after deleting a claim"
