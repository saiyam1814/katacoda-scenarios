#!/bin/bash
echo -n "Deploying Prometheus (obs), Grafana (monitoring) and a demo app"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 3; done
echo ""
echo "Ready. Grafana: monitoring/grafana (port 80). Prometheus: obs/prom (port 9090)."
