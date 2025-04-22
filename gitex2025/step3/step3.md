## Step 3 - Install ArgoCD (NodePort Service)

Now install **ArgoCD**, the GitOps continuous delivery tool, into the cluster. We will expose the ArgoCD API/UI with a NodePort Service so that you can access the web interface:

1. **Install ArgoCD:** Apply the ArgoCD installation manifest.

`kubectl apply -f /home/argocdinstall.yaml`{{exec}}

This deploys ArgoCD components (API server, repository server, controller, UI) in the argocd namespace. The argocd-server Service (ArgoCD API/UI) is created as NodePort.

Initial admin password is stored as a secret in argocd namespace:


In this environment we exposed Argo CD server externally using node port.
2. Get ArgoCD admin password: ArgoCD generates a default admin password on install. Retrieve it with:

`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo`{{exec}}

Copy this password for later. The username is admin.

3. (Optional) Access ArgoCD UI: You can now access the ArgoCD web interface. Open [ACCESS ARGO CD UI]({{TRAFFIC_HOST1_32073}})

At this point, ArgoCD is running and accessible. In the next step, you'll configure ArgoCD to watch your forked Git repository and deploy the application manifests from it.
