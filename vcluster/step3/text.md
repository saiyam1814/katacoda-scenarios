# Step 3: Create a Pod in vCluster

Ensure you are connected to the vCluster context (this should be done automatically in the background):

Create an nginx pod in the vCluster:

`kubectl create deployment nginx --image=nginx` {{exec}

Verify the pod creation by listing the pods:

`kubectl get pods`{{exec}}

This should show the nginx pod in the list.


