#!/bin/bash
echo -n "Preparing the squad-nebula environment"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 2; done
echo ""
echo "Environment ready — the nebula-api Deployment is running in squad-nebula."
echo "Read the task on the left and start when ready."
