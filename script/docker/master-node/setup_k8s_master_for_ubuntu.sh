read -p "Input the Subnet CIDR is the same in variables.tf(Example input: 192.168.0.0): " SUBNET_CIDR_IP

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/custom-resources.yaml -o /home/ubuntu/custom-resources.yaml
sed -i 's/192.168.0.0/'"$SUBNET_CIDR_IP"'/g' /home/ubuntu/custom-resources.yaml
kubectl create -f /home/ubuntu/custom-resources.yaml

kubectl get no -o wide