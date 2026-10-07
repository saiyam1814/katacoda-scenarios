# Scenario

Deployment `web` in namespace `book-cka-service` is healthy, but Service `web` does not return the application.

Fix the existing Service so TCP port `80` reaches the `web` Pods on container port `80`. Keep the Service name and ClusterIP. Do not change the Deployment labels. From the existing `client` Pod, `wget -qO- http://web` must return the NGINX welcome page.

## Validate

Use the **CHECK** button when you are done. You can also run:

```bash
bash /opt/book-labs/cka-02-service-repair/verify.sh
```{{exec}}

Read the failed check and inspect the object before changing anything else.

<details><summary>Solution</summary>

The complete solution is available inside the environment. Read it first, then run it if needed:

```bash
cat /opt/book-labs/cka-02-service-repair/solution.sh
bash /opt/book-labs/cka-02-service-repair/solution.sh
```{{exec}}

Inspect Service selectors, EndpointSlices and target ports. A healthy Pod does not prove that Service traffic can reach it.

</details>
