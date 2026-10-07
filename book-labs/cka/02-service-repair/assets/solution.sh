#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-02-service-repair
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-service patch service web --type=merge -p '{"spec":{"selector":{"app":"web"},"ports":[{"name":"http","port":80,"targetPort":80}]}}'
