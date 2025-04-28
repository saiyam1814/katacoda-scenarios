## Step 1 - Fork and Clone the Repository

GitOps means your Kubernetes manifests live in Git. In this step, you will fork a repository and clone it into the environment:

1. **Fork the repo** `https://github.com/saiyam1814/gitex-workshop` on GitHub. Open [github.com/saiyam1814/gitex-workshop](https://github.com/saiyam1814/gitex-workshop) in a new browser tab and click **Fork** (top-right) to create your own copy of the repository under your GitHub account.

2. **Clone your fork** into this Killercoda environment. Replace `<YOUR_GITHUB_USERNAME>` with your GitHub username in the command below, then run it in the terminal:
`git clone https://github.com/<YOUR_GITHUB_USERNAME>/gitex-workshop.git`{{exec}}
This will create a directory gitex-workshop with the repository content.
3. (Optional) Change into the repository directory and list its contents:
```
cd gitex-workshop
ls -1

```
You should see a deploy/ folder containing the Kubernetes manifests for the demo application.
💡 Tip: Ensure you forked the repo to your own GitHub account. We will configure ArgoCD to watch your fork, so any changes you push will sync to the cluster.
