#!/bin/bash
if [ -n "${CNPE_WORKDIR:-}" ]; then
  [ -f "$CNPE_WORKDIR/investigated" ] || exit 1
else
  [ -f /root/investigated ] || [ -f "$HOME/investigated" ] || exit 1
fi
exit 0
