#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-12-csi-volumes
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
source "$(dirname -- "${BASH_SOURCE[0]}")/helm.sh"
ensure_helm
source "$(dirname -- "${BASH_SOURCE[0]}")/local-node.sh"

reset_ns book-cka-csi
node_exec bash -s <<'HOST'
set -Eeuo pipefail
if ! command -v vgcreate >/dev/null; then apt-get update -qq; DEBIAN_FRONTEND=noninteractive apt-get install -y -qq lvm2; fi
mkdir -p /var/book-labs/cka-csi
if ! vgs book_cka_csi >/dev/null 2>&1; then
 test ! -e /var/book-labs/cka-csi/disk.img || { echo 'Existing disk fixture needs cleanup first'; exit 1; }
 truncate -s 4G /var/book-labs/cka-csi/disk.img
 device=$(losetup --find --show /var/book-labs/cka-csi/disk.img)
 printf '%s\n' "$device" > /var/book-labs/cka-csi/loop.txt
 pvcreate "$device"
 vgcreate book_cka_csi "$device"
fi
expected=$(cat /var/book-labs/cka-csi/loop.txt)
actual=$(pvs --noheadings -o pv_name --select vg_name=book_cka_csi | xargs)
test "$expected" = "$actual"
losetup "$expected" | grep -q /var/book-labs/cka-csi/disk.img
dmsetup targets | grep -q linear
HOST
"$HELM" repo add book-lvm https://openebs.github.io/lvm-localpv --force-update
"$HELM" repo update book-lvm
cat > "$WORK_DIR/lvm-values.yaml" <<'YAML'
analytics:
  enabled: false
crds:
  csi:
    volumeSnapshots:
      enabled: false
lvmNode:
  tolerations:
  - operator: Exists
lvmController:
  tolerations:
  - operator: Exists
YAML
"$HELM" upgrade --install book-lvm book-lvm/lvm-localpv --version 1.10.1 -n book-cka-csi-system --create-namespace -f "$WORK_DIR/lvm-values.yaml" --wait --timeout 5m
for attempt in $(seq 1 60); do
 kubectl -n book-cka-csi-system get lvmnodes.local.openebs.io -o json | python3 -c 'import json,sys; assert any(v["name"]=="book_cka_csi" for n in json.load(sys.stdin)["items"] for v in n.get("volumeGroups",[]))' && break
 sleep 2
done
kubectl delete sc book-cka-expandable --ignore-not-found
rm -f "$WORK_DIR/pvc-uid.txt" "$WORK_DIR/first-pod-uid.txt" "$WORK_DIR/before-kib.txt"
setup_done
