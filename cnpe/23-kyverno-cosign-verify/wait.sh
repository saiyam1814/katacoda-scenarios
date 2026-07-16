#!/bin/bash
echo -n "Installing Kyverno (admission + background controllers)"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 3; done
echo ""
echo "Ready. Kyverno runs cluster-wide; namespace policy-sandbox is your test bench."
echo "Note: signature verification needs internet access to Rekor/Fulcio - this lab has it."
