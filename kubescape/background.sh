curl -sfL https://get.k3s.io | sh -
wget https://github.com/armosec/kubescape/releases/download/v1.0.138/kubescape-ubuntu-latest
chmod +x kubescape-ubuntu-latest 
mv kubescape-ubuntu-latest kubescape
mv kubescape /usr/local/bin/
