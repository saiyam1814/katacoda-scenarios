#!/bin/bash
export COLOR_RESET='\e[0m'
export COLOR_LIGHT_GREEN='\e[0;49;32m' 

# Technique to grab Kubernetes dashboard access token.
# Typically used in Katacoda scenarios.

echo 'To access the dashboard click on the Kubernetes Dashboard tab above this command '
echo 'line. At the sign in prompt select Token and paste in the token that is shown below.'
echo ''
echo 'For Kubernetes clusters exposed to the public, always lock administration access including '
echo 'access to the dashboard. Why? https://www.wired.com/story/cryptojacking-tesla-amazon-cloud/'

SECRET_RESOURCE=$(kubectl get secrets -n kube-system -o name | grep dash-kubernetes-dashboard-token)
ENCODED_TOKEN=$(kubectl get $SECRET_RESOURCE -n kube-system -o=jsonpath='{.data.token}')
export TOKEN=$(echo $ENCODED_TOKEN | base64 --decode)
echo ""
echo "--- Copy and paste this token for dashboard access ---"
echo -e $COLOR_LIGHT_GREEN
echo -e $TOKEN
echo -e $COLOR_RESET