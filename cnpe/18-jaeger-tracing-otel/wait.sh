#!/bin/bash
echo -n "Deploying Jaeger and the span-switch app (pip install takes a minute)"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 3; done
echo ""
echo "Ready. span-switch (ns trace-lab) currently has tracing OFF."
