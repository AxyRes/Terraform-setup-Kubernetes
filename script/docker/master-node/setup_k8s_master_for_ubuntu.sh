read -p "Input the Subnet CIDR is the same in variables.tf(Example input: 192.168.0.0): " SUBNET_CIDR_IP

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


kubectl apply -f https://docs.projectcalico.org/v3.10/manifests/calico.yaml

#kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/tigera-operator.yaml
#curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/custom-resources.yaml -o /home/ubuntu/custom-resources.yaml
#sed -i 's/192.168.0.0/'"$SUBNET_CIDR_IP"'/g' /home/ubuntu/custom-resources.yaml
#kubectl create -f /home/ubuntu/custom-resources.yaml

kubectl get no -o wide

#kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
#kubectl proxy --address='0.0.0.0' --port=8001 --accept-hosts='0.0.0.0,,^0\.0\.0\.0$,^\[:::\]$' --keepalive=100s &