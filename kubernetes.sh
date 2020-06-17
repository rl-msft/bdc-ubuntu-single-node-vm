#!/bin/bash
set -Eeuo pipefail

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

#
KUBE_DPKG_VERSION=1.15.0-00
KUBE_VERSION=1.15.0

#
echo ""
echo "######################################################################################"
echo "Starting installing packages..." 

# Install docker.
#
apt-get update -q

apt --yes install \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    curl

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt update -q
apt-get install -q --yes docker-ce=18.06.2~ce~3-0~ubuntu --allow-downgrades
apt-mark hold docker-ce

usermod --append --groups docker $USER

# Load all pre-requisites for Kubernetes.
#
echo "###########################################################################"
echo "Starting to setup pre-requisites for kubernetes..." 

# Setup the kubernetes preprequisites.
#
echo $(hostname -i) $(hostname) >> /etc/hosts

swapoff -a
sed -i '/swap/s/^\(.*\)$/#\1/g' /etc/fstab

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list

deb http://apt.kubernetes.io/ kubernetes-xenial main

EOF

# Install docker and packages to allow apt to use a repository over HTTPS.
#
apt-get update -q

apt-get install -q -y ebtables ethtool

#apt-get install -y docker.ce

apt-get install -q -y apt-transport-https

# Setup daemon.
#
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
#
systemctl daemon-reload
systemctl restart docker

apt-get install -q -y kubelet=$KUBE_DPKG_VERSION kubeadm=$KUBE_DPKG_VERSION kubectl=$KUBE_DPKG_VERSION

# Holding the version of kube packages.
#
apt-mark hold kubelet kubeadm kubectl
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash

. /etc/os-release
if [ "$UBUNTU_CODENAME" == "bionic" ]; then
    modprobe br_netfilter
fi

# Disable Ipv6 for cluster endpoints.
#
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1

echo net.ipv6.conf.all.disable_ipv6=1 > /etc/sysctl.conf
echo net.ipv6.conf.default.disable_ipv6=1 > /etc/sysctl.conf
echo net.ipv6.conf.lo.disable_ipv6=1 > /etc/sysctl.conf


sysctl net.bridge.bridge-nf-call-iptables=1

echo "Kubernetes pre-requisites have been completed." 

# Setup kubernetes cluster including remove taint on master.
#
echo ""
echo "#############################################################################"
echo "Starting to setup Kubernetes master..." 

# Initialize a kubernetes cluster on the current node.
#
sudo kubeadm init --pod-network-cidr=11.244.0.0/16 --kubernetes-version=$KUBE_VERSION

mkdir -p $HOME/.kube
mkdir -p /home/$SUDO_USER/.kube

sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u $SUDO_USER):$(id -g $SUDO_USER) $HOME/.kube/config

# To enable a single node cluster remove the taint that limits the first node to master only service.
#
master_node=`kubectl get nodes --no-headers=true --output=custom-columns=NAME:.metadata.name`
kubectl taint nodes ${master_node} node-role.kubernetes.io/master:NoSchedule-

# Install the software defined network.
#
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# helm init

kubectl apply -f https://raw.githubusercontent.com/microsoft/sql-server-samples/master/samples/features/sql-big-data-cluster/deployment/kubeadm/ubuntu/rbac.yaml


# Install the dashboard for Kubernetes.
#
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
echo "Kubernetes master setup done."

#Confirm master has no taints 
echo "must read none"
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints --no-headers 

#enable local-storage
cat <<EOF > setup-volumes-agent.sh
# num of persistent volumes
PV_COUNT=50

for i in \$(seq 1 \$PV_COUNT); do
  vol="vol\$i"
 
  mkdir -p /local-storage/\$vol
  mount --bind /local-storage/\$vol /local-storage/\$vol
done
EOF
chmod +x setup-volumes-agent.sh
sudo ./setup-volumes-agent.sh

curl --output local-storage-provisioner.yaml https://raw.githubusercontent.com/rl-msft/bdc-ubuntu-single-node-vm/master/local-storage-provisioner.yaml
kubectl apply -f local-storage-provisioner.yaml


echo "Done!!"
echo ""
echo ""
echo ""


source ~/.bashrc
