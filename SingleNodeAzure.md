
> Disclaimer this is **TEST** script, not tested thoroughly  and not  
> meant for production  
  
  to **deploy** the cluster follow these instructions    
  
 1. Create Ununtu Azure VM along with Windows Azure which will act as   
    you client in same Vnet.  
 2. after the deployment is completed, stop  the VM then increase the OS  
    size to at least 300GB using azure  portal.  
 3. Start the VM, since we are using Ubuntu the new disk space  will be  
    available automatically for the OS disk.  
 4. login with ssh, then issue the following commands, one by one (*those could take  
    up 20 min to  complete*)  
   
    
 ```shell script
 sudo apt-get update && sudo apt-get upgrade 
 curl --output setup-bdc.sh https://raw.githubusercontent.com/rl-msft/bdc-ubuntu-single-node-vm/master/setup-bdc.sh 
 chmod +x setup-bdc.sh 
 sudo ./setup-bdc.sh 
 source ~/.bashrc 
 azdata --version
```
 
 to **Clean up** the VM, run those commands    
    
 ```shell script
curl --output cleanup-bdc.sh https://raw.githubusercontent.com/rl-msft/bdc-ubuntu-single-node-vm/master/cleanup-bdc.sh
chmod +x cleanup-bdc.sh
sudo ./cleanup-bdc.sh
````
