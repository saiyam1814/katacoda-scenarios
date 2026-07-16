#!/bin/bash
H=/root; [ -r /root/cheapest.txt ] || H="$HOME"
[ "$(cat $H/cheapest.txt 2>/dev/null | tr -d '[:space:]')" = "api-alpha" ] || exit 1
[ "$(cat $H/expensive.txt 2>/dev/null | tr -d '[:space:]')" = "api-gamma" ] || exit 1
exit 0
