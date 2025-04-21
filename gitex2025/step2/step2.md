## Step 2 - Install NGINX Ingress Controller (NodePort)

Next, install the NGINX Ingress Controller to manage external access to in-cluster services. We will use the latest **ingress-nginx** controller and expose it via a **NodePort** service:

1. **Deploy ingress-nginx:** Apply the official manifest for the NGINX Ingress Controller.
```
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```
This creates the Ingress controller (in the ingress-nginx namespace) with a Service of type LoadBalancer (default).

2. Expose via NodePort: Patch the Ingress controller Service to NodePort on a known port. We'll use 30080 for HTTP (and 30081 for HTTPS) so we can reach it in this environment:
```
kubectl -n ingress-nginx patch svc ingress-nginx-controller \
  -p '{"spec":{"type":"NodePort","ports":[{"name":"http","nodePort":30080},{"name":"https","nodePort":30081}]}}'

```
This changes the service to NodePort type on ports 30080/30081. These NodePorts will be accessible externally through the Killercoda host.

3. Verify pods: It may take a minute for the NGINX Ingress controller pods to become ready. You can check the status:
```
kubectl -n ingress-nginx get pods -l app.kubernetes.io/name=ingress-nginx

```

The NGINX Ingress Controller is now running and listening on NodePort 30080 for HTTP traffic. In a later step, we will create an Ingress resource and use this controller to access our application.

