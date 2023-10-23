#!/bin/bash
OS="xUbuntu_20.04"
VERSION=1.27
HOME_UBUNTU=/home/ubuntu

echo "**************************************************"
echo "*          Welcome to DOFE                       *"
echo "*    This script is for setup Kubernetes Cluster *"
echo "* - version 1.20.0 and will make this node       *"
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
ufw disable
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
swapoff -a
mount -a

# Update the package list and install required packages
apt update -y
apt install -y curl apt-transport-https ca-certificates git wget

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -  
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list
apt-get update -y
apt install -y kubeadm=$VERSION.0-00 kubectl=$VERSION.0-00 kubelet=$VERSION.0-00
apt-mark hold kubelet kubeadm kubectl

modprobe overlay
modprobe br_netfilter
tee /etc/sysctl.d/kubernetes.conf<<EOF 
net.bridge.bridge-nf-call-ip6tables = 1 
net.bridge.bridge-nf-call-iptables = 1 
net.ipv4.ip_forward = 1 
EOF
sysctl --system

echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | apt-key add -

apt update -y
apt-get install -y cri-o cri-o-runc
sed -i "s/10.85.0.0/$SUBNET_CIDR_IP/g" /etc/cni/net.d/100-crio-bridge.conflist
systemctl daemon-reload
systemctl restart crio
systemctl enable crio
systemctl enable kubelet
kubeadm config images pull --cri-socket unix:///var/run/crio/crio.sock
sysctl -p


#Install Master Node
kubeadm init --pod-network-cidr=$SUBNET_CIDR_IP/16 --cri-socket unix:///var/run/crio/crio.sock

echo "Kubernetes master node setup is complete!"



