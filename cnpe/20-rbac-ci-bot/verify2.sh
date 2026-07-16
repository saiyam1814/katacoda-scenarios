#!/bin/bash
AS="--as=system:serviceaccount:build-room:ci-bot"

[ "$(kubectl auth can-i create deployments -n build-room $AS)" = "yes" ] || exit 1
[ "$(kubectl auth can-i delete deployments -n build-room $AS)" = "no" ] || exit 1
[ "$(kubectl auth can-i create deployments -n default $AS)" = "no" ] || exit 1
[ "$(kubectl auth can-i get secrets -n build-room $AS)" = "no" ] || exit 1
[ "$(kubectl auth can-i create configmaps -n build-room $AS)" = "yes" ] || exit 1

[ -f /root/ci-bot-perms.txt ] || [ -f "$HOME/ci-bot-perms.txt" ] || exit 1
exit 0
