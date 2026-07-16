#!/bin/bash
T=/root/triage.txt; [ -r "$T" ] || T="$HOME/triage.txt"
[ -f "$T" ] || exit 1
grep -qi "quota" "$T" || exit 1
grep -qi "secret" "$T" || exit 1
grep -qi "pvc\|persistentvolumeclaim\|volume" "$T" || exit 1
exit 0
