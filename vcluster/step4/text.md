# Step 4: Expose Pod using NodePort

Expose the nginx pod using a NodePort service:

`kubectl expose deployment nginx --type=NodePort --name=nginx-service` {{exec}}

Verify the service creation and get the NodePort URL:

`kubectl get services` {{exec}}

Find the NodePort URL and visit it in your browser:

`echo "http://$(hostname -I | awk '{print $1}'):$(kubectl get svc nginx-service -o jsonpath='{.spec.ports[0].nodePort}')"` {{exec}}
