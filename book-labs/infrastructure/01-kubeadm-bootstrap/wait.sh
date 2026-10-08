#!/usr/bin/env bash
(
  set -eu
  state="${BOOK_LAB_STATE_ROOT:-/tmp/book-labs}/infra-01-kubeadm-bootstrap"
  printf 'Preparing the infrastructure lab'
  for attempt in $(seq 1 600); do
    if test -f "$state/error"; then printf '\n'; cat "$state/error" >&2; exit 1; fi
    if test -f "$state/ready"; then printf '\nReady. Start with the task.\n'; exit 0; fi
    printf '.'; sleep 2
  done
  printf '\nSetup exceeded 20 minutes. Inspect %s/setup.log.\n' "$state" >&2
) || :
