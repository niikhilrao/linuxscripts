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
hostname subca
echo "subca" > /etc/hostname
echo -e "127.0.0.1\tsubca.$DOMIANNAME\tsubca" >> /etc/hosts
apt-get install dos2unix tree openssl -y
echo -e "${RED} Enter the ip of the Dns server or where it will be configured ${NC}"
read dnsip
echo -e "domain $DOMIANNAME\nsearch $DOMIANNAME\nnameserver $dnsip" > /etc/resolv.conf
chattr +i /etc/resolv.conf
echo -e "${RED} \t Now Configuring ssh Please Please <Enter> key only  ${NC}"
ssh-keygen -q
echo -e "Please Provide the rootca machine password for easy config"
ssh-copy-id root@rootca
echo -e "${RED} Creating Directory for subca "
mkdir /root/subca/
echo "Entering subca directory "
cd /root/subca/
echo -e "clearing the directory for setup ${NC}" 
rm -rf /root/subca/*
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt index.txt.attr
echo 1000 > serial
echo 1000 > crlnumber
cp $CURRENT_DIR/subca.cnf .
dos2unix subca.cnf
openssl genrsa -aes256 -out private/subca.key.pem
chmod 700 private/
chmod 400 private/subca.key.pem 
openssl req -config subca.cnf -new -sha256 -key private/subca.key.pem -out csr/subca.csr.pem
echo -e "${RED} Now copying the CSR to Rootca for signing from rootca , Please Enter the password for root user in rootca if asked ${NC} "
#################
scp csr/subca.csr.pem root@rootca:/root/rootca/subca/csr/
ssh root@rootca "openssl ca -config /root/rootca/rootca.cnf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in /root/rootca/subca/csr/subca.csr.pem -out /root/rootca/subca/certs/subca.cert.pem"
ssh root@rootca << EOF
chmod 444 /root/rootca/subca/certs/subca.cert.pem
cat /root/rootca/certs/ca.cert.pem /root/rootca/subca/certs/subca.cert.pem >> /root/rootca/certs/ca-chain.cert.pem
chmod 444 /root/rootca/certs/ca-chain.cert.pem
exit
EOF

######################
scp root@rootca:/root/rootca/{subca/certs/subca.cert.pem,certs/ca-chain.cert.pem} certs/



