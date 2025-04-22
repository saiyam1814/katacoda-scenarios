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
`export RAW_URL=$(sed 's/PORT/30080/g' /etc/killercoda/host)`{{exec}}
`export INGRESS_HOST=${RAW_URL#*://}`{{exec}}

Example output

```
echo $INGRESS_HOST
37e083f13c97-10-244-4-10-30080.papa.r.killercoda.com
```
```
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: gitex-app
spec:
  rules:
  - host: "${INGRESS_HOST}"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: gitex-service      # adjust to your Service name
            port:
              number: 80
EOF
```

3. Note on ArgoCD sync: This manual patch changes the live cluster state. ArgoCD will show the application as OutOfSync because the cluster's Ingress host no longer matches what’s in Git. In a real scenario, you would update the Git manifest and let ArgoCD sync it. For this workshop, patching directly is fine to enable external access.
Your application’s Ingress is now configured with the correct host. In the next step, you will access the application through this Ingress URL to verify everything is working.
