#!/bin/bash
OS="xUbuntu_20.04"
VERSION=1.27

echo "**************************************************"
echo "*          Welcome to DOFE                       *"
echo "*    This script is for setup kubernetes cluster *"
echo "*  and will make this node become a master       *"
echo "*  Thanks for using code of AxyRes               *"
echo "**************************************************"
echo \n\n
read -p "Enter the IP address or hostname of the Kubernetes master node: " MASTER_NODE_IP
echo Start Install and Setup Kubernetes Master Node\n

sudo ufw disable

# Update the package list and install required packages
sudo apt update -y
sudo apt install -y curl apt-transport-https ca-certificates gnupg-agent software-properties-common gnupg git wget cri-o cri-o-runc

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y
sudo apt install -y docker-ce containerd.io

systemctl enable docker
systemctl start docker

# Add the 'ubuntu' user to the 'docker' group
sudo usermod -aG docker ubuntu

# Add Kubernetes repository and install kubeadm, kubelet, and kubectl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update -y
sudo apt install -y kubeadm=1.18.5-00 kubelet=1.18.5-00 kubectl=1.18.5-00
sudo apt-mark hold kubelet kubeadm kubectl

echo "Check version of kubectl and kubeadm............................................................"
kubectl version --client && kubeadm version

sudo mount -a
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

sudo modprobe overlay
sudo modprobe br_netfilter

cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | apt-key add -

sudo sed -i 's/10.85.0.0/172.24.0.0/g' /etc/cni/net.d/100-crio-bridge.conflist
systemctl daemon-reload
systemctl restart crio
systemctl enable crio
systemctl status crio
systemctl enable kubelet

kubeadm config images pull --cri-socket unix:///var/run/crio/crio.sock

# Copy the Kubernetes config to your user's home directory
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Initialize the Kubernetes cluster
# Replace <your-pod-network-cidr> with your preferred Pod network CIDR
sudo kubeadm init --apiserver-advertise-address=$MASTER_NODE_IP --pod-network-cidr=10.50.0.0/16  --ignore-preflight-errors=all --cri-socket unix:///var/run/crio/crio.sock

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/tigera-operator.yaml
# Install a Pod network add-on (Calico in this example)
#kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml

# Allow scheduling of pods on the master node (not recommended for production)
#kubectl taint nodes --all node-role.kubernetes.io/master-

# Verify the cluster status
#kubectl get nodes

echo "Kubernetes master node setup is complete!"