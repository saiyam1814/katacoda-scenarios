#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-05-image-admission
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin

bash "$(dirname "$0")/base-setup.sh"
# Verified upstream pause:3.10 multi-platform manifest digest; the Pod must really start.
image=registry.k8s.io/pause@sha256:ee6521f290b2168b6e0935a181d4cff9be1ac3f505666ef0e3c98fae8199917a
printf '%s' "$image" > "$STATE_DIR/pause-image"
kubectl -n book-cks-images run debug-target --image="$image"
ready_pod book-cks-images debug-target

setup_done
