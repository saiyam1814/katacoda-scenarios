curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
minikube start --extra-config=kubeadm.ignore-preflight-errors=NumCPU --force --cpus=1
sudo apt update -y
sudo apt -y install vim git curl wget kubectl=1.24.3-00
alias k='kubectl'
