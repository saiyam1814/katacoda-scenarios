## Step 4 - Create a GitOps Application in ArgoCD

Now that ArgoCD is running, let's configure it to deploy our application from the Git repository. We will create an **ArgoCD Application** CR that points to your fork of the repo, under the `deploy/` path:

1. **Prepare the Application manifest:** The YAML below defines an ArgoCD `Application`. It tells ArgoCD which Git repo and path to sync, and that sync is automated. **Replace `<YOUR_GITHUB_USERNAME>` with your GitHub username** in the repo URL, then apply the manifest:
```
   kubectl apply -f - <<EOF
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: gitex-app
     namespace: argocd
   spec:
     project: default
     source:
       repoURL: 'https://github.com/saiyam1814/gitex-workshop'
       path: deploy/
       targetRevision: main
     destination:
       server: 'https://kubernetes.default.svc'
     syncPolicy:
       automated: {}
     syncOptions:
       - CreateNamespace=true
   EOF
```

