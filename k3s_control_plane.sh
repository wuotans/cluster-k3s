#!/bin/bash
sudo apt-get update
sudo apt-get upgrade --yes

sudo apt-get install curl gpg apt-transport-https nfs-common vim --yes

# mkdir -p /var/lib/rancher/k3s/server/manifests
# cat <<EOF | sudo tee /var/lib/rancher/k3s/server/manifests/traefik-config.yaml
# apiVersion: helm.cattle.io/v1
# kind: HelmChartConfig
# metadata:
#   name: traefik
#   namespace: kube-system
# spec:
#   valuesContent: |-
#     additionalArguments:
#       - "--api"
#       - "--api.dashboard=true"
#       - "--api.insecure=true"
#       - "--log.level=DEBUG"
#       - "--serversTransport.insecureSkipVerify=true"
#     ports:
#       traefik:
#         expose: true
#       websecure:
#         tls:
#           enabled: true
#       web:
#         redirectTo:
#           port: websecure
#     providers:
#       kubernetesCRD:
#         allowCrossNamespace: true
# EOF

# curl -sfL https://get.k3s.io | sh -s - server --write-kubeconfig-mode "0644" --flannel-backend=none --disable-network-policy --disable=traefik --tls-san 172.31.255.100 --node-external-ip 172.31.255.100 --cluster-cidr 192.168.0.0/16 --cluster-init
# curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-backend=none --cluster-cidr 172.26.0.0/16 --service-cidr 172.27.0.0/16 --tls-san 172.31.255.100 --node-external-ip 172.31.255.100 --disable-network-policy --disable=traefik" sh -
# curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-backend=none --cluster-cidr 172.26.0.0/16 --service-cidr 172.27.0.0/16 --tls-san 172.31.255.100 --disable-network-policy --disable=traefik" sh -
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-backend=none --cluster-cidr 172.26.0.0/16 --service-cidr 172.27.0.0/16 --tls-san 172.31.255.100 --node-ip 172.31.255.100 --disable-network-policy --disable=traefik" sh -
# curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-backend=none --cluster-cidr 172.26.0.0/16 --service-cidr 172.27.0.0/16 --tls-san 172.31.255.100 --disable-network-policy --disable=traefik" sh -

# /usr/local/bin/k3s server --flannel-backend=none --cluster-cidr 172.26.0.0/16 --service-cidr 172.27.0.0/16 --tls-san 172.31.255.100 --disable-network-policy --disable=traefik --node-ip 172.31.255.100
echo "KUBECONFIG=/etc/rancher/k3s/k3s.yaml" | sudo tee --append /etc/environment

# For Vagrant re-runs, check if there is existing configs in the location and delete it for saving new configuration.
mkdir --parents /vagrant/configs
rm --force /vagrant/configs/*
K3S_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
echo "curl -sfL https://get.k3s.io | K3S_URL=https://172.31.255.100:6443 K3S_TOKEN=$K3S_TOKEN sh -" | sudo tee /vagrant/configs/join.sh
sudo cat /etc/rancher/k3s/k3s.yaml | sudo tee /vagrant/configs/kube-config
sudo sed -i 's@127.0.0.1@172.31.255.100@g' /vagrant/configs/kube-config

# Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm --yes

# cat <<EOF | sudo tee -a /etc/hosts
# 172.31.255.103      k3s-nfs.al.mt.gov.br
# EOF

# sudo apt-get install ufw -y
# sudo sed -i "s@IPV6=yes@IPV6=no@g" /etc/default/ufw
# sudo ufw default deny incoming
# sudo ufw default allow outgoing
# sudo ufw enable
# sudo ufw allow 6443/tcp
# sudo ufw allow 443/tcp

# /var/lib/rancher/k3s/server/manifests/traefik-config.yaml

# novo!!
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
sleep 5s
kubectl create -f /vagrant/calico/custom-resources.yaml
sleep 5s
kubectl apply -f /vagrant/calico/configMap.yaml
sleep 15s
kubectl patch installation.operator.tigera.io default --type merge -p '{"spec":{"calicoNetwork":{"linuxDataplane":"BPF"}}}'

# #	Configure Traefik
kubectl apply -f /vagrant/traefik/secret.yaml
kubectl apply -f /vagrant/traefik/ingress.yaml

# # Instalando Traefik
# helm repo add traefik https://traefik.github.io/charts
# helm repo update

# helm upgrade --install --values /vagrant/traefik/values.yaml traefik traefik/traefik --namespace traefik --create-namespace

# #	Instalando App Whoami
# kubectl apply -f /vagrant/whoami/whoami.yml  