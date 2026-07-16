#!/bin/bash
echo "Installing Prometheus + OpenCost + three workloads."
echo "This one takes 2-4 minutes - cost tooling needs a metrics pipeline."
echo -n "Working"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 3; done
echo ""
echo "Environment ready. OpenCost gets more accurate as scrape data accumulates,"
echo "but allocation data is queryable right away."
