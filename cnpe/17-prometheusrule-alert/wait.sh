#!/bin/bash
echo "Installing the Prometheus Operator, a Prometheus instance, and a frontend app."
echo -n "Working"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 3; done
echo ""
echo "Ready. Prometheus 'main' (ns monitoring) selects rules labelled release=prometheus."
echo "The frontend app is already serving ~8% HTTP 500s. Your alert should notice."
