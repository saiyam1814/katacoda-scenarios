#!/bin/bash
echo -n "Installing Gatekeeper and the forbidfloatingtag template"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 3; done
echo ""
echo "Ready. ConstraintTemplate forbidfloatingtag (kind: ForbidFloatingTag) is in place."
