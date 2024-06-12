# Step 2: Create a vCluster

Create a vCluster named `awesome-demo` in the `team-x` namespace with the following command:

`vcluster create awesome-demo --namespace team-x` {{exec}}

Connect to the newly created vCluster and run the connection in the background:

`nohup vcluster connect awesome-demo --namespace team-x &>/dev/null &` {{exec}}

Verify the vCluster creation by listing the vClusters:

`vcluster list --namespace team-x` {{exec}}

This should show `awesome-demo` in the list of vClusters.

