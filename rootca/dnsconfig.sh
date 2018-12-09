#!/bin/bash
CURRENT_DIR=$(pwd)
MASK='s'
RED='\033[0;31m'
NC='\033[0m'
read -p "Enter the ip address of the base repo ftp hosted " iprepo
echo -e "deb\tftp://$iprepo/debian/\tjessie\tmain" > /etc/apt/sources.list
apt-get update 
echo -e "${RED} Enter the domain name example: rao.com or hackme.local ${NC}"
read DOMIANNAME
hostname ser1
echo "ser1" > /etc/hostname
echo -e "127.0.0.1\tser1.$DOMIANNAME\tser1" >> /etc/hosts
apt-get install dos2unix tree openssl bind9 apache2 dnsutils -y
echo -e "${RED} Enter the IP of This MAchine ${NC}"
read dnsip
echo -e "domain $DOMIANNAME\nsearch $DOMIANNAME\nnameserver $dnsip" > /etc/resolv.conf
chattr +i /etc/resolv.conf
echo "include \"/etc/bind/named.conf.zone.$DOMIANNAME\";" >> /etc/bind/named.conf
reverseip=$(echo $dnsip| awk -F "." '{ print $3"."$2"."$1}')
echo -e "zone \"$DOMIANNAME\" { \n \t type master; \n \t file \"/etc/bind/db.$DOMIANNAME\"; \n }; \n zone \"$reverseip.in-addr.apra\" { \n \t type master; \n\t file \"/etc/bind/db.$reverseip\"; \n };" > /etc/bind/named.conf.zone.$DOMIANNAME
###
###
###
cd /etc/bind
cp db.local db.$DOMIANNAME
cp db.127 db.$reverseip
sed -i "s/localhost/ser1.$DOMIANNAME/g" db.$DOMIANNAME
sed -i "s/127.0.0.1/$dnsip/g" db.$DOMIANNAME
echo -e "ser1\tIN\tA\t$dnsip" >> db.$DOMIANNAME
echo -e "${RED} Enter the ip address of Root CA : "  
read rootcaip
echo -e " Enter the ip address of Sub CA : ${NC}"
read subcaip
echo -e "www\tIN\tCNAME\tser1" >> db.$DOMIANNAME
echo -e "rootca\tIN\tA\t$rootcaip" >> db.$DOMIANNAME
echo -e "subca\tIN\tA\t$subcaip" >> db.$DOMIANNAME

#########################################
#### reverse zone configuration ######
##############################
sed -i "s/localhost/ser1.$DOMIANNAME/g" db.$reverseip
sed -i "s/1\.0\.0/$(echo $dnsip| awk -F "." '{ print $4}')/g" db.$reverseip
echo -e "$(echo $rootcaip| awk -F "." '{ print $4}')\tIN\tPTR\trootca.$DOMIANNAME." >> db.$reverseip
echo -e "$(echo $subcaip| awk -F "." '{ print $4}')\tIN\tPTR\tsubca.$DOMIANNAME." >> db.$reverseip
systemctl start bind9
systemctl restart bind9

