#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-08-static-pods-logs
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
reset_ns book-cka-hostpods

node_exec() { if [[ -n ${BOOK_LAB_NODE_CONTAINER:-} ]]; then docker exec -i "$BOOK_LAB_NODE_CONTAINER" "$@"; else sudo "$@"; fi; }

STATIC_DIR=$(node_exec awk '/^staticPodPath:/ {print $2}' /var/lib/kubelet/config.yaml)
test -n "$STATIC_DIR" || fail 'kubelet staticPodPath was not found'
printf '%s\n' "$STATIC_DIR" > "$WORK_DIR/static-dir.txt"
node_exec rm -f "$STATIC_DIR/book-cka-static.yaml"
rm -f "$WORK_DIR/mirror-before.txt" "$WORK_DIR/c2.txt" "$WORK_DIR/previous.txt"
kubectl apply -f - <<'YAML'
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "logs-demo",
    "namespace": "book-cka-hostpods"
  },
  "spec": {
    "containers": [
      {
        "name": "c1",
        "image": "busybox:1.37.0",
        "command": [
          "sh",
          "-c",
          "echo c1-not-the-answer; sleep 3600"
        ]
      },
      {
        "name": "c2",
        "image": "busybox:1.37.0",
        "command": [
          "sh",
          "-c",
          "echo c2-required-log; sleep 3600"
        ]
      }
    ]
  }
}
---
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "crash",
    "namespace": "book-cka-hostpods"
  },
  "spec": {
    "containers": [
      {
        "name": "app",
        "image": "busybox:1.37.0",
        "command": [
          "sh",
          "-c",
          "if ! test -f /state/restarted; then touch /state/restarted; echo \"ERROR: missing configuration\"; sleep 2; exit 1; fi; echo restarted; sleep 3600"
        ],
        "volumeMounts": [
          {
            "name": "state",
            "mountPath": "/state"
          }
        ]
      }
    ],
    "volumes": [
      {
        "name": "state",
        "emptyDir": {}
      }
    ]
  }
}
YAML

ready_pod book-cka-hostpods logs-demo
for i in $(seq 1 60); do
 count=$(kubectl -n book-cka-hostpods get pod crash -o jsonpath='{.status.containerStatuses[0].restartCount}')
 [[ ${count:-0} -ge 1 ]] && break
 sleep 2
done
[[ ${count:-0} -ge 1 ]] || fail 'Previous-instance log fixture did not restart'
setup_done
