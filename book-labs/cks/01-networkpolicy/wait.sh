#!/usr/bin/env bash
# Killercoda injects foreground commands into the learner's interactive shell.
# Isolate shell options and exits; report setup failures without closing that shell.
(
  set -eu
  state="${BOOK_LAB_STATE_ROOT:-/tmp/book-labs}/cks-01-networkpolicy"
  printf 'Preparing the scenario'
  for attempt in $(seq 1 240); do
    if test -f "$state/error"; then printf '\n'; cat "$state/error" >&2; exit 1; fi
    if test -f "$state/ready"; then printf '\nReady. Start with the task in the left panel.\n'; exit 0; fi
    printf '.'; sleep 2
  done
  printf '\nSetup timed out. Inspect %s/setup.log and Creator Debug.\n' "$state" >&2
  exit 1
) || :
