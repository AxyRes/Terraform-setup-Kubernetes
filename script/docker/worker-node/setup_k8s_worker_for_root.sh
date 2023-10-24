#!/bin/bash
VERSION=1.27

echo "**************************************************"
echo "*          Welcome to DOFE                       *"
echo "*    This script is for setup Kubernetes Cluster *"
echo "* - version 1.27.0 and will make this node       *"
echo "*  become to a master node                       *"
echo "*         Thanks for using code of AxyRes        *"
echo "**************************************************"
echo \n\n
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as the root user."
    echo "Please use 'sudo' to run the script."
    exit 1
fi
read -p "Enter the number in order of the node: " NODE
read -p "Input the Subnet CIDR is the same in variables.tf(Example input: 192.168.0.0): " SUBNET_CIDR_IP
read -p "Enter the IP address or hostname of the Kubernetes master node: " MASTER_NODE_IP
read -p "Enter the Kubernetes token: " TOKEN
read -p "Enter the discovery token CA cert hash: " DISCOVERY_TOKEN_CA_CERT_HASH
echo Start Install and Setup Kubernetes Master Node\n

hostnamectl set-hostname "axyres-worker-node0$NODE"


apt-get update -y
apt-get install -y docker.io apt-transport-https ca-certificates git wget

systemctl restart docker
systemctl enable docker

usermod -aG docker ubuntu

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -  
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list
apt-get update -y
apt install -y kubeadm=$VERSION.0-00 kubectl=$VERSION.0-00 kubelet=$VERSION.0-00
apt-mark hold kubelet kubeadm kubectl

kubeadm join $MASTER_NODE_IP:6443 --token $TOKEN --discovery-token-ca-cert-hash $DISCOVERY_TOKEN_CA_CERT_HASH
echo "Kubernetes worker node $NODE setup is complete!"