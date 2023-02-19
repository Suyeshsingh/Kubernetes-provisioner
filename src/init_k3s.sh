#!/bin/sh


echo "Installing dependencies"
{
apt-get update && apt-get upgrade -y
apt-get install expect -y
clear
}
echo -n "Please enter IP address you want to advertise i.e loadbalancer then press [ENTER]:"
read advr_ip
export advr_ip
sleep 1s
clear


##############################################################
################# K3s Control plain Install ##################
##############################################################

echo  "Starting k3s installation"
#{
#find $path/src/install_k3s.sh -type f -exec chmod 777 {} \;
#sh $path/src/install_k3s.sh
#}
echo "Disabling swap"
swapoff -a; sed -i '/swap/d' /etc/fstab

echo "Disabling Firewall"
{
systemctl disable --now ufw
}
{
curl -sfL https://get.k3s.io |INSTALL_K3S_VERSION=v1.25.6+k3s1 sh -s - --advertise-address=$advr_ip --disable=traefik,servicelb,local-storage - server  --cluster-init
rm -rf $HOME/.kube/config
sudo cat /etc/rancher/k3s/k3s.yaml >> $HOME/.kube/config
}
clear
sleep 1s

###############################################################
#################### Adding Worker Node #######################
###############################################################

while true
do
clear
echo "The list of available option than can now be performed are as follows:"
echo "Press 1 to add control plain node"
echo "Press 2 to add worker node"
echo "Press 0 to exit"
echo -n "Enter your option then press [ENTER]:"
read node
if [ $node = 1 ]; then
sleep 1s
clear
 echo "Please enter the ip address of the master node i.e 192.168.1.1  "
 echo -n "then press[ENTER]:" 
 read w_ip
 export w_ip
sleep 1s
clear
 echo "please enter user name of the master node"
 echo -n "then press [ENTER]:"
 read uname
 export uname
sleep 1s
clear
 echo  "please enter master node password"
 echo -n "then press [ENTER]:"
 read pword
 export pword
sleep 1s
clear
 echo "Initializing Node"
 {
 export token=$token$(cat /var/lib/rancher/k3s/server/node-token)
 find $path/src/add_k3s_master.exp -type f -exec chmod 777 {} \;
 expect $path/src/add_k3s_master.exp $uname $w_ip $pword $path $advr_ip $token
 }
clear
elif [ $node = 2 ]; then
 echo "Please enter the ip address of the worker node i.e 192.168.1.1  "
 echo -n "then press[ENTER]:" 
 read w_ip
 export w_ip
sleeps 1s
clear
 echo "please enter user name of the worker node"
 echo -n "then press [ENTER]:"
 read uname
 export uname
sleep 1s
clear 
echo  "please enter worker node password"
 echo -n "then press [ENTER]:"
 read pword
 export pword
sleep 1s
clear
 echo "setup worker"
 {
 export token=$token$(cat /var/lib/rancher/k3s/server/node-token)
 find $path/src/add_k3s_worker.exp -type f -exec chmod 777 {} \;
 expect $path/src/add_k3s_worker.exp $uname $w_ip $pword $path $advr_ip $token
 }
clear
elif [ $node = 0 ]; then
sleep 1s
clear
echo "The program will now exit"
sleep 2s
exit 1

else
 echo "Invalind option"
 echo "Please enter a correct option"
sleep 2s
clear

fi
done
