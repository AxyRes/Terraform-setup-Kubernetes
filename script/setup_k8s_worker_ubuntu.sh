#!/bin/bash
OS="xUbuntu_20.04"
VERSION=1.27

# Replace these variables with your values
read -p "Enter the IP address or hostname of the Kubernetes master node: " MASTER_NODE_IP
read -p "Enter the Kubernetes token: " TOKEN
read -p "Enter the discovery token CA cert hash: " DISCOVERY_TOKEN_CA_CERT_HASH


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

# Join the worker node to the cluster
sudo kubeadm join $MASTER_NODE_IP:6443 --token $TOKEN --discovery-token-ca-cert-hash $DISCOVERY_TOKEN_CA_CERT_HASH

# Allow scheduling of pods on the master (if needed)
#kubectl taint nodes --all node-role.kubernetes.io/master-

# To verify the node has joined the cluster successfully
kubectl get nodes


kubectl get cs
# After joining the node, you may need to apply a CNI plugin for networking
# For example, Calico:
# kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml