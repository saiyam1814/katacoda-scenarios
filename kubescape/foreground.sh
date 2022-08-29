apt install jq -y
curl -sfL https://get.k3s.io | sh -
VERSION=$(curl -L --silent "https://api.github.com/repos/armosec/kubescape/releases/latest" | jq -r .tag_name)
wget https://github.com/armosec/kubescape/releases/download/$VERSION/kubescape-ubuntu-latest
chmod +x kubescape-ubuntu-latest 
mv kubescape-ubuntu-latest kubescape
mv kubescape /usr/local/bin/
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
