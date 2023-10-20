#!/bin/bash

# Update the package list and install required packages
sudo apt update -y
sudo apt install -y curl apt-transport-https

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add Kubernetes repository and install kubeadm, kubelet, and kubectl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update -y
sudo apt install -y kubeadm kubelet kubectl

# Disable swap
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a

# Initialize the Kubernetes cluster
# Replace <your-pod-network-cidr> with your preferred Pod network CIDR
sudo kubeadm init --pod-network-cidr=10.50.0.0/16

# Copy the Kubernetes config to your user's home directory
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install a Pod network add-on (Calico in this example)
kubectl apply -f https://docs.projectcalico.org/v3.20/manifests/calico.yaml

# Allow scheduling of pods on the master node (not recommended for production)
kubectl taint nodes --all node-role.kubernetes.io/master-

# Verify the cluster status
kubectl get nodes

echo "Kubernetes master node setup is complete!"