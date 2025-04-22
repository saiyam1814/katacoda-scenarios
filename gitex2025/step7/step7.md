## Step 7 - Modify Git and Observe ArgoCD Sync

Finally, let's experience GitOps in action. You will change something in your Git repository and watch ArgoCD automatically apply the update to the cluster:

1. **Edit the code in Git:** On your forked GitHub repository page (which you forked in Step 1), navigate to the `deploy/` directory. Change the `index.html` file.

2. **Wait for ArgoCD to sync:** ArgoCD polls the Git repo periodically (every few minutes) for changes. It will detect your commit and automatically apply it. After a short wait (typically up to 3 minutes), ArgoCD will create the new pod to match the desired replicas.

3. **Observe the change:** Check the application pods in the cluster:
```
   APP_NS=$(kubectl get ingress -A -o jsonpath='{.items[0].metadata.namespace}')
   kubectl -n $APP_NS get pods
```
You should see 2 pods for your application now (it was 1 before). One pod is the original, and the second was created due to the replica count change. Both should reach Running state.

4. (Optional) Refresh ArgoCD UI: If you have the ArgoCD web UI open, you will notice the application is back to Synced once the new state is applied. The UI would show the new changes.
Congratulations! 🎉 You have successfully triggered a GitOps deployment. By editing code in Git, ArgoCD detected the change and synchronized the Kubernetes cluster state to match the Git state, all without manual kubectl intervention. You have completed the workshop scenario. In a real-world workflow, you could continue making Git commits to drive cluster changes, and ArgoCD would keep everything in sync.