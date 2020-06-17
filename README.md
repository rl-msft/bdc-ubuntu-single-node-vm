# Deploy bdc on Ubuntu 18.04 single node using Azure VM 



> **Disclaimer** this is ***Experimental*** deployment script, not to be used in ***Production*** under any circumstances
  
  to **deploy** the cluster follow these instructions    
  
 1. Create Ubuntu Azure VM along with Windows Azure VM  in the same Vnet, Windows VM will act as    
    your client to access the portals etc.
 2. Once the VM deployment completed, stop  the VM then increase the OS Disk
    size to at least 300GB using azure  portal.  
 3. Start the VM, since we are using Ubuntu the new disk space will be available automatically for the OS disk.  
 4. Login with ssh, then issue the following commands, one by one (*those could take up to 20 min to complete*)  

Non-AD
    
```shell script
 sudo apt-get update 
 sudo apt-get upgrade 
 curl --output setup-bdc.sh https://raw.githubusercontent.com/rl-msft/bdc-ubuntu-single-node-vm/master/setup-bdc.sh 
 chmod +x setup-bdc.sh 
 sudo ./setup-bdc.sh 
 source ~/.bashrc 
 azdata --version
```

AD (edit endpoint and security json files to meet your requirements and AD objects)
 
```shell script
 sudo apt-get update 
 sudo apt-get upgrade 
 curl --output setup-bdc.sh https://raw.githubusercontent.com/rl-msft/bdc-ubuntu-single-node-vm/master/setup-bdc-ad.sh
 curl --output endpoint-patch.json https://raw.githubusercontent.com/rl-msft/bdc-ubuntu-single-node-vm/master/endpoint-patch.json
 curl --output security-patch.json https://raw.githubusercontent.com/rl-msft/bdc-ubuntu-single-node-vm/master/security-patch.json
 chmod +x setup-bdc.sh 
 sudo ./setup-bdc.sh 
 source ~/.bashrc 
 azdata --version
```

to install only kubernetes cluster 

```shell script
 sudo apt-get update 
 sudo apt-get upgrade 
 curl --output kubernetes.sh https://raw.githubusercontent.com/rl-msft/bdc-ubuntu-single-node-vm/master/kubernetes.sh
 chmod +x kubernetes.sh 
 sudo ./kubernetes.sh
 kubectl get pods -A
```
 to **Clean up** the VM, run those commands    
    
 ```shell script
curl --output cleanup-bdc.sh https://raw.githubusercontent.com/rl-msft/bdc-ubuntu-single-node-vm/master/cleanup-bdc.sh
chmod +x cleanup-bdc.sh
sudo ./cleanup-bdc.sh
````
