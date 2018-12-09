#!/bin/bash 
RED='\033[0;31m'
NC='\033[0m'
yum remove -y ypserv
echo -e "${RED} NIs COnfig AutO ScripT "
read -p "Enter the NisDomain Name Given in Quesition default: " nisdname
echo -e " ${RED} Setting nisdomainname to $nisdname and hostname to nis1.$nisdname ${NC}"

read -p "Enter the IP address of secondary (slave) " slaveip

$(nisdomainname $nisdname)
$(hostname nis1.$nisdname)
$(echo "NISDOMAIN=$nisdname" > /etc/sysconfig/network)
$(echo "nis1.$nisdname" > /etc/hostname)
$(echo -e "$slaveip\tnis2.$nisdname" >> /etc/hosts)
$(echo -e "/home\t*(rw,sync)" > /etc/exports)
$(exportfs -a)
yum install -y ypserv
$(systemctl start ypserv)
$(systemctl start rpcbind)
$(systemctl stop firewalld)
$(setenforce 0)
echo -e "\t${RED} Now Configuring the files make File ${NC}"
cd /var/yp
$(sed -i '127s/.*/all: passwd group shadow #hosts #rpc #services #netid #protocols #mail \\/' Makefile)
$(sed -i '23s/.*/NOPUSH=false/' Makefile)

/usr/lib64/yp/ypinit -m

$(systemctl restart ypserv)
$(systemctl restart rpcbind)
$(systemctl start yppasswdd)
$(systemctl start ypxfrd)
$(systemctl start nfs)
echo -e "${RED} Clearing History ${NC} "

$(history -c)
