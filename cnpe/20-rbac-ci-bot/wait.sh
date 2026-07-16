#!/bin/bash
echo -n "Preparing build-room"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 1; done
echo ""
echo "Ready."
