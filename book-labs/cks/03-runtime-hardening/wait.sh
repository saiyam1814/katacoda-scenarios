#!/usr/bin/env bash
(
set -Eeuo pipefail
state="${BOOK_LAB_STATE_ROOT:-/tmp/book-labs}/cks-03-runtime-hardening"
for attempt in $(seq 1 900); do
 if test -f "$state/ready"; then echo 'Ready. Open the first step.'; break; fi
 if test -f "$state/error"; then cat "$state/error"; break; fi
 if (( attempt % 20 == 0 )); then echo "Preparing the real lab components ($attempt seconds). Logs: $state/setup.log"; fi
 sleep 1
done
if ! test -f "$state/ready"; then echo "Setup incomplete. Inspect $state/setup.log before starting."; fi
true
) || :
