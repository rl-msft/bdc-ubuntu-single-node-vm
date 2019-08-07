curl --output setup-bdc.sh https://raw.githubusercontent.com/microsoft/sql-server-samples/master/samples/features/sql-big-data-cluster/deployment/kubeadm/ubuntu-single-node-vm/setup-bdc.sh

chmod +x setup-bdc.sh

sudo ./setup-bdc.sh

source ~/.bashrc

azdata --version
