Disclaimer this is TEST script, not tested thoroughly  and not meant for production

**Instructions**

1) Create Ununtu Azure VM
2) after the deployment is completed, stop the VM then increase the OS size to at least 300GB
3) Start the VM and login with ssh, then issue the following commands


`sudo apt-get update && sudo apt-get upgrade `

`curl --output setup-bdc.sh https://raw.githubusercontent.com/microsoft/sql-server-samples/master/samples/features/sql-big-data-cluster/deployment/kubeadm/ubuntu-single-node-vm/setup-bdc.sh
`

`chmod +x setup-bdc.sh
`
`sudo ./setup-bdc.sh
`

`source ~/.bashrc
`

`azdata --version
`