This Killercoda secenario is a kubesolo playground.
## Export KUBECONFIG
`export KUBECONFIG=/var/lib/kubesolo/pki/admin/admin.kubeconfig
`{{execute}}
## Cluster is ready
Keep trying  `kubectl get nodes`{{execute}} unless ready ;) 

## Deploy the Application once ready.

`kubectl apply -f https://raw.githubusercontent.com/portainer/kubesolo/develop/examples/mosquitto.yaml`{{execute}}