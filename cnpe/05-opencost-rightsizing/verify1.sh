#!/bin/bash
RESULT_DIR="${CNPE_WORKDIR:-/root}"
if [ -z "${CNPE_WORKDIR:-}" ] && [ ! -r "$RESULT_DIR/cheapest.txt" ]; then
  RESULT_DIR="$HOME"
fi
[ "$(tr -d '[:space:]' < "$RESULT_DIR/cheapest.txt")" = "api-alpha" ] || exit 1
[ "$(tr -d '[:space:]' < "$RESULT_DIR/expensive.txt")" = "api-gamma" ] || exit 1
exit 0
