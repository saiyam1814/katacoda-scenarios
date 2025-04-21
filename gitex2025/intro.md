# GitOps Workshop (Gitex Asia 2025)

Welcome to the GitOps workshop for **Gitex Singapore 2025**! In this hands-on scenario, you will set up a Kubernetes 1.32 cluster with ArgoCD and deploy a sample application using GitOps principles. You will learn how to: 

- **Fork a Git repository** containing Kubernetes manifests.
- **Install NGINX Ingress Controller** on Kubernetes using a **NodePort** service for external access.
- **Install ArgoCD** for GitOps continuous delivery, also exposed via **NodePort**.
- **Create an ArgoCD Application** pointing to your Git repository (fork) to deploy manifests automatically.
- **Patch Ingress** resources to use the correct hostname from the Killercoda environment.
- **Verify the application** is accessible through the Ingress.
- **Make a change in Git** and see ArgoCD automatically synchronize the cluster to the new desired state.

**Prerequisites:** A GitHub account (to fork the repository). The Kubernetes cluster (v1.32) is provided in this environment, and **kubectl** is pre-installed.

Proceed to the next step to get started by forking the repository and cloning it into the environment. Click **Start** to begin.
