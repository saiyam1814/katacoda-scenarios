# Repair and build a minimal image

Repair `build/Dockerfile` to use BusyBox 1.37.0, copy only index.html to /site, run as user 1000:1000 and serve port 8080. Exclude developer-secret.txt using .dockerignore; no APP_TOKEN may remain. Build with Buildah, import the actual image into containerd, and run Deployment/Service `web` in `book-cks-supply` using `localhost/book-cks-web:v1` with imagePullPolicy Never, read-only root, no privilege escalation and all capabilities dropped. The actual built application must answer HTTP; do not substitute a registry image.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-07-supply-chain/solution.sh
bash /opt/book-labs/cks-07-supply-chain/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
