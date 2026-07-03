# Step 1: Install Chaos Mesh and Deploy a Target App

Chaos Mesh runs **inside** your cluster as an operator. In this step you'll install it with Helm and deploy the application we'll be breaking.

## Wait for Background Setup

The environment pre-pulls the Chaos Mesh images and adds the Helm repo. Make sure that's done:

```bash
until [ -f /tmp/.chaos-mesh-setup-done ]; do echo "waiting for background setup..."; sleep 5; done
echo "Setup complete - helm repo added, images pre-pulled."
```{{exec}}

## Install Chaos Mesh

One important detail: the **chaos-daemon** injects faults by entering target containers through the node's container runtime, so it must know which runtime your cluster uses. This cluster runs **containerd**, so we point Chaos Mesh at the containerd socket:

```bash
helm install chaos-mesh chaos-mesh/chaos-mesh \
  --namespace chaos-mesh \
  --version 2.8.3 \
  --set chaosDaemon.runtime=containerd \
  --set chaosDaemon.socketPath=/run/containerd/containerd.sock \
  --set dashboard.securityMode=false
```{{exec}}

> `dashboard.securityMode=false` disables dashboard login for this playground. In production, leave it on and issue RBAC-scoped tokens per team.

Wait for all components to come up:

```bash
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=chaos-mesh -n chaos-mesh --timeout=300s
kubectl get pods -n chaos-mesh -o wide
```{{exec}}

You should see:

- **chaos-controller-manager** (x3) - reconciles experiment CRDs
- **chaos-daemon** (one per node, privileged) - injects the actual faults
- **chaos-dashboard** - the web UI (we'll use it in Step 4)

## Chaos Experiments Are CRDs

Chaos Mesh installed a set of **CustomResourceDefinitions** - one per fault type:

```bash
kubectl get crds | grep chaos-mesh
```{{exec}}

`podchaos`, `networkchaos`, `stresschaos`, `iochaos`, `httpchaos`, `timechaos`, `workflows`... Each is a declarative fault you can `kubectl apply`, version in git, and gate with RBAC. This is the core design difference from CLI-driven chaos tools.

## Deploy the Target Application

Same drill as any chaos experiment - we need something to break. An nginx Deployment with **3 replicas**, plus a client pod we'll use to measure network behavior in Step 3:

```bash
kubectl create deployment nginx --image=nginx --replicas=3 -n demo
kubectl expose deployment nginx --port=80 -n demo
kubectl run client --image=curlimages/curl -n demo --command -- sleep 86400
kubectl rollout status deployment/nginx -n demo --timeout=120s
kubectl wait --for=condition=ready pod/client -n demo --timeout=120s
kubectl get pods -n demo -o wide --show-labels
```{{exec}}

Note the `app=nginx` label - Chaos Mesh experiments select their targets by namespace and label, exactly like Services do.

Everything is in place. Time to break things - declaratively.
