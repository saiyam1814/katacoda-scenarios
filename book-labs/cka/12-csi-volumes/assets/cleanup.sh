#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-12-csi-volumes
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
source "$(dirname -- "${BASH_SOURCE[0]}")/helm.sh"
ensure_helm
source "$(dirname -- "${BASH_SOURCE[0]}")/local-node.sh"

kubectl delete namespace book-cka-csi --ignore-not-found
kubectl delete sc book-cka-expandable --ignore-not-found
"$HELM" uninstall book-lvm -n book-cka-csi-system --wait
kubectl delete namespace book-cka-csi-system --ignore-not-found
kubectl delete crd lvmnodes.local.openebs.io lvmvolumes.local.openebs.io lvmsnapshots.local.openebs.io --ignore-not-found
node_exec bash -s <<'HOST'
set -Eeuo pipefail
if vgs book_cka_csi >/dev/null 2>&1; then
 test -z "$(lvs --noheadings -o lv_name book_cka_csi)" || { echo 'Live logical volumes remain; refusing to remove their VG'; exit 1; }
 device=$(cat /var/book-labs/cka-csi/loop.txt)
 losetup "$device" | grep -q /var/book-labs/cka-csi/disk.img
 vgremove -y book_cka_csi
 pvremove -y "$device"
 losetup -d "$device"
fi
rm -rf /var/book-labs/cka-csi
HOST
rm -f "$STATE_DIR/ready"
