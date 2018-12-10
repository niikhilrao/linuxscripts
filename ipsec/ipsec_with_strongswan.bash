#!/bin/bash

CURRENT_DIR=$(pwd)
RED='\033[0;31m'
NC='\033[0m'

echo -e "\t Welcome to Ipsec with StrongSwan "
if [ $# -lt 1 ] 
then
echo -e "Please Enter The Machine Number Ex.${RED} $0 1 ${NC} or ${RED} $0 2 ${NC} or sono .. "
exit 1

fi

read -p "Enter the ip address of the base repo ftp hosted " iprepo
echo -e "deb\tftp://$iprepo/debian/\tjessie\tmain" > /etc/apt/sources.list
apt-get update 
apt-get install strongswan tcpdump -y
echo -e "${RED} Please Enter the Number of machines (Excluing own Machine) you want to configure ${NC}" 
read NOOFMACHINE
echo -e "Please Enter Your IP Address " 
read SELFIP
for i in `seq 1 $NOOFMACHINE`
do
if [ $1 -eq $i ]
then
NUMB=$(expr $i + 1)
STARTORROUTE="start"
else 
NUMB=$i
STARTORROUTE="route"
fi
echo "Enter the Ip address of $i Machine "
read MACHINEIP
echo "$SELFIP $MACHINEIP : PSK \"Password123\"" >> /etc/ipsec.secrets
echo -e "conn deb$1-deb$NUMB\n\ttype=transport\n\tauthby=secret\n\tleft=$SELFIP\n\tright=$MACHINEIP\n\tpfs=yes\n\tauto=$STARTORROUTE" > /etc/ipsec.d/deb$1-deb$NUMB.conf
done
echo "include /etc/ipsec.d/*.conf" >> /etc/ipsec.conf
systemctl restart ipsec
systemctl status ipsec
