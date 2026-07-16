#!/bin/bash
echo -n "Breaking the metrics-portal stack (on purpose)"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 2; done
echo ""
echo "Done. metrics-portal is now suitably on fire. Good luck."
