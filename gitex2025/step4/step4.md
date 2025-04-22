## Step 4 - Create a GitOps Application in ArgoCD

Now that ArgoCD is running, let's configure it to deploy our application from the Git repository. We will create an **ArgoCD Application** CR that points to your fork of the repo, under the `deploy/` path:

1. **Prepare the Application manifest:** The YAML below defines an ArgoCD `Application`. It tells ArgoCD which Git repo and path to sync, and that sync is automated. **Replace `<YOUR_GITHUB_USERNAME>` with your GitHub username** in the repo URL, then apply the manifest:
`kubectl apply -f /home/application.yaml`{{exec}}

This command uses a heredoc to apply the manifest directly. Ensure the repoURL points to your fork (not the original repo).

2. ArgoCD creates the app: After a few moments, ArgoCD will register this Application and start syncing it. It will create the Kubernetes resources defined under deploy/ in your repo. The syncPolicy.automated setting means ArgoCD applies changes automatically.

3. Verify sync status: Check that the Application has been created and is synced:
```
kubectl -n argocd get applications.argoproj.io gitex-app

```
Look for STATUS Synced and HEALTH Healthy. ArgoCD has now deployed the app manifests from your repository into the cluster.

ArgoCD is now continuously monitoring your forked repository. The demo application's Kubernetes objects (Deployment, Service, Ingress, etc.) should be running in the cluster (ArgoCD created a new namespace for them, thanks to CreateNamespace=true). In the next step, we'll expose the application via the Ingress by patching its host.
