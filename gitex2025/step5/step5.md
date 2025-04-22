## Step 5 - Patch Ingress for External Access

The application deployed via ArgoCD likely includes an **Ingress** resource (under `deploy/`) for exposing the app. However, that Ingress is configured with a placeholder host (a dummy hostname). In this step, you will patch the Ingress to use the actual host address provided by the Killercoda environment, so you can access it externally.

1. **Find the Ingress:** List the Ingress resources in the cluster to identify the one created for the app:
```
   kubectl get ingress -A
```
You should see an Ingress in the new application namespace (created by ArgoCD). Take note of its name and namespace.

2. Patch the Ingress host: Use the following commands to patch the Ingress host to the environment's URL. This will replace the host field with the correct Killercoda subdomain:
ssh node01
`ssh node01`{{exec}}
export the host to be used
`export INGRESS_HOST=$(sed 's/PORT/30525/g' /etc/killercoda/host)`{{exec}}
```
INGRESS_NS=$(kubectl get ingress -A -o jsonpath='{.items[0].metadata.namespace}')
INGRESS_NAME=$(kubectl get ingress -A -o jsonpath='{.items[0].metadata.name}')
HOST_DOMAIN="[[HOST_SUBDOMAIN]]-30080-[[KATACODA_HOST]].environments.katacoda.com"
kubectl -n $INGRESS_NS patch ingress $INGRESS_NAME --type=json -p "[{\"op\": \"replace\", \"path\": \"/spec/rules/0/host\", \"value\": \"${HOST_DOMAIN}\"}]"

```

This sets the Ingress host to the correct subdomain for port 30080. Now, any requests to http://$HOST_DOMAIN will be routed to your application service inside the cluster.

3. Note on ArgoCD sync: This manual patch changes the live cluster state. ArgoCD will show the application as OutOfSync because the cluster's Ingress host no longer matches what’s in Git. In a real scenario, you would update the Git manifest and let ArgoCD sync it. For this workshop, patching directly is fine to enable external access.
Your application’s Ingress is now configured with the correct host. In the next step, you will access the application through this Ingress URL to verify everything is working.
