#!/bin/bash 
RED='\033[0;31m'
NC='\033[0m'
yum remove -y ypserv
echo -e "${RED} NIs COnfig AutO ScripT "
read -p "Enter the NisDomain Name Given in Quesition default: " nisdname
read -p "Enter the ip of master server: " ipmaster
echo -e " ${RED} Setting nisdomainname to $nisdname and hostname to nis2.$nisdname ${NC}"
$(nisdomainname $nisdname)
$(hostname nis2.$nisdname)
$(echo "NISDOMAIN=$nisdname" > /etc/sysconfig/network)
$(echo "nis2.$nisdname" > /etc/hostname)
$(echo -e "/home\t*(rw,sync)" > /etc/exports)
$(exportfs -a)
$(echo -e "$ipmaster\tnis1.$nisdname" >> /etc/hosts)

yum install -y ypserv
$(systemctl start ypserv)
$(systemctl start rpcbind)
$(systemctl stop firewalld)
$(setenforce 0)
echo -e "\t${RED} Now Configuring the files make File ${NC}"
cd /var/yp
$(sed -i '127s/.*/all: passwd group shadow #hosts #rpc #services #netid #protocols #mail \\/' Makefile)

/usr/lib64/yp/ypinit -s nis1.$nisdname

$(systemctl restart ypserv)
$(systemctl restart rpcbind)
$(systemctl start yppasswdd)
$(systemctl start nfs)
echo -e "${RED} Clearing History ${NC} "

$(history -c)
