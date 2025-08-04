#!/bin/bash
sudo apt-get update
sudo apt-get upgrade --yes

sudo apt-get install curl gpg apt-transport-https nfs-common vim --yes

curl -sfL https://get.k3s.io | sh -s - server --write-kubeconfig-mode "0644" --tls-san 172.31.255.100 --cluster-cidr 172.26.0.0/16 --service-cidr 172.27.0.0/16 --cluster-init
echo "KUBECONFIG=/etc/rancher/k3s/k3s.yaml" | sudo tee --append /etc/environment
cat <<EOF | sudo tee /var/lib/rancher/k3s/server/manifests/traefik-config.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    additionalArguments:
      - "--api"
      - "--api.dashboard=true"
      - "--api.insecure=true"
      - "--log.level=DEBUG"
      - "--serversTransport.insecureSkipVerify=true"
    ports:
      traefik:
        expose: true
      websecure:
        tls:
          enabled: true
      web:
        redirectTo:
          port: websecure
    providers:
      kubernetesCRD:
        allowCrossNamespace: true
EOF

# For Vagrant re-runs, check if there is existing configs in the location and delete it for saving new configuration.
mkdir --parents /vagrant/configs
rm --force /vagrant/configs/*
K3S_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
echo "curl -sfL https://get.k3s.io | K3S_URL=https://172.31.255.100:6443 K3S_TOKEN=$K3S_TOKEN sh -" | sudo tee /vagrant/configs/join.sh
sudo cat /etc/rancher/k3s/k3s.yaml | sudo tee /vagrant/configs/kube-config

# Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm --yes

cat <<EOF | sudo tee -a /etc/hosts
172.31.255.103      k3s-nfs.al.mt.gov.br
EOF

# kubectl apply -f /vagrant/traefik/helm-chart-config.yaml
# kubectl apply -f /vagrant/traefik/secret.yaml
# kubectl apply -f /vagrant/traefik/tls-store.yaml
# kubectl apply -f /vagrant/traefik/ingress.yaml

# sudo apt-get install ufw -y
# sudo sed -i "s@IPV6=yes@IPV6=no@g" /etc/default/ufw
# sudo ufw default deny incoming
# sudo ufw default allow outgoing
# sudo ufw enable
# sudo ufw allow 6443/tcp
# sudo ufw allow 443/tcp