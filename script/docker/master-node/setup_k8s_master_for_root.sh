#!/bin/bash
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
read -p "Enter the IP address or hostname of the Kubernetes master node: " MASTER_NODE_IP
echo Start Install and Setup Kubernetes Master Node\n

hostnamectl set-hostname "axyres-master-node"

# Install Docker

apt-get update -y
apt-get install -y docker.io apt-transport-https ca-certificates git wget nfs-common

systemctl restart docker
systemctl enable docker

usermod -aG docker ubuntu


# Install Kubenetes

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl


# Start Kubenetes Master
kubeadm init --apiserver-advertise-address=$MASTER_NODE_IP --pod-network-cidr=$SUBNET_CIDR_IP/16
echo "Kubernetes master node setup is complete!"

#
#Check token list: kubeadm token list
#Create new token: kubeadm token create
#Discovery token ca cert hash: 
#openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
#openssl dgst -sha256 -hex | sed 's/^.* //'