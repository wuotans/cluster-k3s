#!/bin/bash
# https://kubedemy.io/kubernetes-storage-part-1-nfs-complete-tutorial
sudo apt-get update
sudo apt-get upgrade --yes

sudo apt-get install nfs-server vim parted --yes
sudo mkdir --parents /data

cat <<EOF | sudo tee -a /etc/exports
/data           172.31.255.100(rw,sync,no_root_squash,no_subtree_check)
EOF

sudo systemctl enable --now nfs-server

cat <<EOF | sudo tee -a /etc/hosts
172.31.255.100      k3s-control-plane.al.mt.gov.br
EOF

sudo systemctl restart nfs-server.service
echo -e 'yes\nyes' | sudo parted ---pretend-input-tty /dev/sda resizepart 1 100%
sudo resize2fs -f /dev/sda1