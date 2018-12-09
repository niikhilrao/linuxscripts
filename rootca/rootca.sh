#!/bin/bash
CURRENT_DIR=$(pwd)
MASK='s'
RED='\033[0;31m'
NC='\033[0m'
read -p "Enter the ip address of the base repo ftp hosted" iprepo
echo -e "deb\tftp://$iprepo/debian/\tjessie\tmain" > /etc/apt/sources.list
apt-get update 
echo -e "${RED} Enter the domain name example: rao.com or hackme.local ${NC}"
read DOMIANNAME
hostname rootca
echo "rootca" > /etc/hostname
echo -e "127.0.0.1\trootca.$DOMIANNAME\trootca" >> /etc/hosts
apt-get install dos2unix tree openssl -y
echo -e "${RED} Enter the ip of the Dns server or where it will be configured ${NC}"
read dnsip
echo -e "domain $DOMIANNAME\nsearch $DOMIANNAME\nnameserver $dnsip" > /etc/resolv.conf
chattr +i /etc/resolv.conf
mkdir /root/rootca
cd /root/rootca
mkdir -p certs crl newcerts private subca/certs subca/csr
chmod 700 private
touch index.txt index.txt.attr
echo 1000 > serial
echo 1000 > crlnumber
cp $CURRENT_DIR/rootca.cnf .
dos2unix rootca.cnf
openssl genrsa -aes256 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem
echo -e "${RED} Now generating certificate for Root ca Please Enter the info carefully ${NC}"
openssl req -config rootca.cnf -key private/ca.key.pem -extensions v3_ca -new -x509 -days 7300 -sha256 -out certs/ca.cert.pem
chmod 444 certs/ca.cert.pem
