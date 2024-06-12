# Step 4: Expose Pod using NodePort

Expose the nginx pod using a NodePort service:

`kubectl expose deployment nginx --type=NodePort --name=nginx-service --port 80`{{exec}}

Verify the service creation and get the NodePort URL:

`kubectl get services`{{exec}}

Get the NodePort:

`NODE_PORT=$(kubectl get svc nginx-service -o jsonpath='{.spec.ports[0].nodePort}')`{{exec}}

Create a link to access the nginx service:

`sed "s/PORT/$NODE_PORT/g" /etc/killercoda/host | sed "s#{{TRAFFIC_HOST1_PORT}}#{{TRAFFIC_HOST1_$NODE_PORT}}#g"`{{exec}}
