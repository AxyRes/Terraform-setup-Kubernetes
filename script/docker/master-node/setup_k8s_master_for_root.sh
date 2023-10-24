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
read -p "Input the Subnet CIDR is the same in variables.tf(Example input: 192.168.0.0): " SUBNET_CIDR_IP
echo Start Install and Setup Kubernetes Master Node\n

hostnamectl set-hostname "axyres-master-node"


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


kubeadm init --pod-network-cidr=$SUBNET_CIDR_IP/16
echo "Kubernetes master node setup is complete!"

#
#Check token list: kubeadm token list
#Create new token: kubeadm token create
#Discovery token ca cert hash: 
#openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
#openssl dgst -sha256 -hex | sed 's/^.* //'