#!/bin/bash

launch.sh

# Log script activity (https://serverfault.com/a/103569)
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/log/init-background.log 2>&1
set -x	

# Common curl switches (however, use `lynx url --dump` when you can)
echo '-s' >> ~/.curlrc

# Allow pygmentize for source highlighting of source files (YAML, Dockerfile, Java, etc)
# Preload docker image to make ccat hot
docker run whalebrew/pygmentize:2.6.1 &
echo 'function ccat() { docker run -it -v "$(pwd)":/workdir -w /workdir whalebrew/pygmentize:2.6.1 $@; }' >> ~/.bashrc
source ~/.bashrc

# Setup dashboard on port 30000 (but don't wait as repo is sometimes slow)
{ helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/; \
helm install dash kubernetes-dashboard/kubernetes-dashboard \
--version=2.3.0 \
--namespace kube-system \
--set=image.tag=v2.0.3 \
--set=service.type=NodePort \
--set=enableInsecureLogin=true \
--set=service.nodePort=30000 \
--set=service.externalPort=80; } &

# Katacoda Cloud Provider is used when a LoadBalancer service is requested 
# by Kubernetes, Katacoda will respond with the IP of the master. This is 
# how Istio and other LoadBalancer based services can be deployed.
kubectl delete -f /opt/katacoda-cloud-provider.yaml &

echo "done" >> /opt/.backgroundfinished
