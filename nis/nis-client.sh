#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'
$(systemctl stop firewalld)
$(setenforce 0)
echo -e "NIS Config For Client"

read -p "Enter the Ip Address of NIS SERVER(master) " ip
read -p "Enter the Ip Address of NIS Slave " ipslave
read -p "Enter The Domain name Given to Server " nisdname
echo -e " ${RED} Setting nisdomainname to $nisdname and hostname to nis3.$nisdname ${NC}"

$(echo "NISDOMAIN=$nisdname" > /etc/sysconfig/network)
$(echo "nis3.$nisdname" > /etc/hostname)
$(echo -e "$ip\tnis1.$nisdname" >> /etc/hosts)
$(echo -e "$ipslave\tnis2.$nisdname" >> /etc/hosts)
$(nisdomainname $nisdname)
$(hostname nis3.$nisdname)

config_nis_client () {
yum install -y ypbind autofs
$(echo "domain $2 server $1" > /etc/yp.conf)
$(echo "domain $2 server $3" >> /etc/yp.conf)
$(echo "domain $2 broadcast" >> /etc/yp.conf)
#$(echo "ypserver $1 " >> /etc/yp.conf)
#$(echo "ypserver $3 " >> /etc/yp.conf)
echo "Starting Ypbind Server"
systemctl start rpcbind
systemctl start ypbind
ypcat passwd 
authconfig-tui
echo -e "/home\t/etc/auto.nfs --timeout 600" >> /etc/auto.master
echo "* -fstype=nfs4,rw,soft,intr $ip:/home/& " >> /etc/auto.nfs
systemctl start autofs
}


if ping -c 1 -w 2 $ip ;then
	echo "Server Found Starting configuation"
	config_nis_client $ip $nisdname $ipslave
else
	echo "Hey unable to Find Server Please Check if Both Client and Server Are in same Vmnat and pinging each other"
fi

