#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

kubectl create namespace flags-lab --dry-run=client -o yaml | kubectl apply -f -

# The CR the app teams want to apply - given to the candidate as the contract
cat <<'EOF' > /root/checkout-express.yaml
apiVersion: toggle.acme.dev/v1beta1
kind: FeatureFlag
metadata:
  name: checkout-express
  namespace: flags-lab
spec:
  key: checkout.express
  enabled: true
  rolloutPercent: 25
EOF

touch /tmp/.cnpe-setup-done
