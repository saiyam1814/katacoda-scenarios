# Step 7: Port Forwarding and kubectl exec

In this step, we'll learn about two essential tools for interacting with your Kubernetes applications: **port forwarding** and **kubectl exec**. These are crucial for development, debugging, and testing.

## Understanding Port Forwarding

**Port Forwarding** allows you to access services and pods running inside your Kubernetes cluster from your local machine. It creates a secure tunnel between your local machine and the cluster.

### Why Use Port Forwarding?

- 🔧 **Development** - Test services locally without exposing them publicly
- 🐛 **Debugging** - Access services that are only available inside the cluster
- 🧪 **Testing** - Use local tools (browser, curl, Postman) to test cluster services
- 🔒 **Security** - No need to expose services publicly during development

## Understanding kubectl exec

**kubectl exec** allows you to execute commands inside a running container, similar to `docker exec`. It's essential for:
- 🔍 **Debugging** - Inspect container state, check logs, test connectivity
- 🛠️ **Troubleshooting** - Run diagnostic commands inside containers
- 📊 **Monitoring** - Check resource usage, processes, network connections
- 🧹 **Maintenance** - Perform administrative tasks

## Check Current Pods

Let's see what pods we have running:

```bash
kubectl get pods -n k8s-primer
```{{exec}}

## Port Forward to a Pod

Let's port forward to one of our nginx pods. First, get a pod name:

```bash
POD_NAME=$(kubectl get pods -n k8s-primer -l app=webapp -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -z "$POD_NAME" ]; then
    POD_NAME=$(kubectl get pods -n k8s-primer -l app=nginx-deployment -o jsonpath='{.items[0].metadata.name}')
fi
echo "Using pod: $POD_NAME"
```{{exec}}

Now, let's start a port forward in the background:

```bash
kubectl port-forward pod/$POD_NAME 8080:80 -n k8s-primer > /tmp/port-forward.log 2>&1 &
sleep 2
```{{exec}}

## Verify Port Forward is Running

Check if port forward is active:

```bash
ps aux | grep "kubectl port-forward" | grep -v grep
```{{exec}}

## Test Port Forward Access

Now you can access the pod via localhost:

```bash
curl -s http://localhost:8080 | head -20
```{{exec}}

The port forward maps:
- **Local port 8080** → **Container port 80**

## Port Forward to a Service

You can also port forward directly to a service (which will route to one of the pods):

```bash
kubectl port-forward svc/webapp-service 8081:80 -n k8s-primer > /tmp/port-forward-svc.log 2>&1 &
sleep 2
```{{exec}}

Test it:

```bash
curl -s http://localhost:8081 | head -20
```{{exec}}

## Understanding Port Forward Syntax

The syntax is:
```bash
kubectl port-forward <resource-type>/<resource-name> <local-port>:<remote-port>
```

Examples:
- `kubectl port-forward pod/my-pod 8080:80` - Forward local 8080 to pod port 80
- `kubectl port-forward svc/my-service 3000:80` - Forward local 3000 to service port 80
- `kubectl port-forward deployment/my-deployment 9000:8080` - Forward to deployment

## Stop Port Forwarding

To stop a port forward, find and kill the process:

```bash
pkill -f "kubectl port-forward.*8080"
pkill -f "kubectl port-forward.*8081"
```{{exec}}

Or if running in foreground, use `Ctrl+C`.

## Using kubectl exec

Now let's learn about `kubectl exec`. First, get a pod name:

```bash
POD_NAME=$(kubectl get pods -n k8s-primer -l app=webapp -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -z "$POD_NAME" ]; then
    POD_NAME=$(kubectl get pods -n k8s-primer -l app=nginx-deployment -o jsonpath='{.items[0].metadata.name}')
fi
echo "Using pod: $POD_NAME"
```{{exec}}

## Execute a Simple Command

Run a simple command inside the container:

```bash
kubectl exec $POD_NAME -n k8s-primer -- ls -la /usr/share/nginx/html
```{{exec}}

## Execute an Interactive Shell

Get an interactive shell inside the container:

```bash
kubectl exec -it $POD_NAME -n k8s-primer -- /bin/bash
```{{exec}}

**Note**: Not all containers have `/bin/bash`. Some use `/bin/sh`:

```bash
kubectl exec -it $POD_NAME -n k8s-primer -- /bin/sh
```{{exec}}

## Understanding kubectl exec Syntax

The syntax is:
```bash
kubectl exec <pod-name> [flags] -- <command>
```

Flags:
- **`-it`** - Interactive terminal (stdin + tty)
- **`-c <container>`** - Specify container name (for multi-container pods)
- **`--`** - Separates kubectl options from the command to execute

## Check Container Environment

Let's check environment variables:

```bash
kubectl exec $POD_NAME -n k8s-primer -- env | head -10
```{{exec}}

## Check Network Connectivity

Test network connectivity from inside the pod:

```bash
kubectl exec $POD_NAME -n k8s-primer -- curl -s http://localhost:80 | head -10
```{{exec}}

## Check Processes

See what processes are running:

```bash
kubectl exec $POD_NAME -n k8s-primer -- ps aux
```{{exec}}

## Check Resource Usage

If the container has `top` or similar tools:

```bash
kubectl exec $POD_NAME -n k8s-primer -- cat /proc/meminfo | head -5
```{{exec}}

## Execute Commands in Specific Container

For pods with multiple containers, specify which container:

```bash
# kubectl exec <pod-name> -c <container-name> -n <namespace> -- <command>
```

## Create a Test File

Let's create a test file inside the container:

```bash
kubectl exec $POD_NAME -n k8s-primer -- sh -c "echo 'Hello from inside the container!' > /tmp/test.txt"
kubectl exec $POD_NAME -n k8s-primer -- cat /tmp/test.txt
```{{exec}}

## Understanding Container Isolation

Important points about `kubectl exec`:
- ✅ Commands run **inside the container**
- ✅ Changes are **ephemeral** (lost when container restarts)
- ✅ You have the **same permissions** as the container user
- ✅ **No access** to host filesystem (unless mounted)
- ✅ **Isolated** from other containers

## Debugging Workflow

A typical debugging workflow:

1. **Check pod status**: `kubectl get pods`
2. **View logs**: `kubectl logs <pod-name>`
3. **Describe pod**: `kubectl describe pod <pod-name>`
4. **Exec into pod**: `kubectl exec -it <pod-name> -- /bin/sh`
5. **Test connectivity**: `curl`, `wget`, `ping`
6. **Check files**: `ls`, `cat`, `grep`
7. **Port forward**: `kubectl port-forward pod/<pod-name> <port>`

## Port Forward vs Service Types

| Method | Use Case | Access |
|--------|----------|--------|
| **Port Forward** | Development, debugging | Local machine only |
| **NodePort** | External access, testing | Anyone with node IP |
| **LoadBalancer** | Production external access | Public internet |
| **ClusterIP** | Internal cluster access | Cluster pods only |

## Best Practices

### Port Forwarding
- ✅ Use for development and debugging
- ✅ Don't use in production (use proper services)
- ✅ Stop port forwards when done
- ✅ Use different local ports to avoid conflicts

### kubectl exec
- ✅ Use for debugging and troubleshooting
- ✅ Don't modify production containers directly
- ✅ Use read-only commands when possible
- ✅ Be careful with write operations
- ✅ Remember changes are ephemeral

## Key Takeaways

- ✅ **Port forwarding** creates secure tunnels to cluster resources
- ✅ Syntax: `kubectl port-forward <resource>/<name> <local>:<remote>`
- ✅ Works with pods, services, and deployments
- ✅ **kubectl exec** runs commands inside containers
- ✅ Use `-it` for interactive shells
- ✅ Use `--` to separate kubectl options from commands
- ✅ Both tools are essential for debugging
- ✅ Changes made via exec are ephemeral
- ✅ Port forwarding is for development, not production

## What's Next?

Congratulations! You've completed the Kubernetes Primer. You now understand:
- ✅ Pods, Deployments, Services, and NodePort Services
- ✅ YAML manifests (declarative approach)
- ✅ Resource management (requests and limits)
- ✅ Port forwarding and kubectl exec

You're ready to move on to advanced Kubernetes workshops like the LLM on Kubernetes workshop!

---

**Port forwarding and exec mastered?** You've completed the Kubernetes Primer! 🎉
