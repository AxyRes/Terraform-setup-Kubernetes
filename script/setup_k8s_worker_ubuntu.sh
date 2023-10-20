#!/bin/bash

# Replace these variables with your values
read -p "Enter the IP address or hostname of the Kubernetes master node: " MASTER_NODE_IP
read -p "Enter the Kubernetes token: " TOKEN
read -p "Enter the discovery token CA cert hash: " DISCOVERY_TOKEN_CA_CERT_HASH

# Install kubeadm, kubelet, and kubectl
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl

# Join the worker node to the cluster
sudo kubeadm join $MASTER_NODE_IP:6443 --token $TOKEN --discovery-token-ca-cert-hash $DISCOVERY_TOKEN_CA_CERT_HASH

# Allow scheduling of pods on the master (if needed)
kubectl taint nodes --all node-role.kubernetes.io/master-

# To verify the node has joined the cluster successfully
kubectl get nodes

# After joining the node, you may need to apply a CNI plugin for networking
# For example, Calico:
# kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml