#!/bin/bash

CURRENT_DIR=$(pwd)
MASK='s'
RED='\033[0;31m'
NC='\033[0m'
read -p "Enter the ip address of the base repo ftp hosted" iprepo
echo -e "deb\tftp://$iprepo/debian/\tjessie\tmain" > /etc/apt/sources.list
apt-get update 
apt-get install easy-rsa openvpn -y
mkdir -p /etc/easy-rsa/ /etc/openvpn
cp -r /usr/share/easy-rsa/ /etc/
cd /etc/easy-rsa/
mkdir -p keys dh
cp vars backup.conf.bak
sed -i 's/KEY_NAME=\"EasyRSA\"/KEY_NAME=\"ser\"/' vars
openssl dhparam -out dh/dh2048.pem 2048
. ./vars
./clean-all
echo -e "${RED} Enter details for Rootca Configuration VPN ${NC}"
./build-ca
echo -e "${RED} Enter Details for Server Configuration VPN ${NV}"
./build-key-server ser
cp keys/{ca.crt,ser.key,ser.crt} /etc/openvpn/
cp dh/dh2048.pem /etc/openvpn
echo -e "${RED} Enter Details for Client Configuration in clt files VPN ${NC}"
./build-key clt
gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz > /etc/openvpn/server.conf
cd /etc/openvpn/
sed -i 's/dh dh1024.pem/dh \/etc\/openvpn\/dh2048.pem/' server.conf
sed -i '/;user.*/s/^;//' server.conf
sed -i '/;group.*/s/^;//' server.conf
sed -i 's/ca ca.crt/ca \/etc\/openvpn\/ca.crt/' server.conf
sed -i 's/cert server.crt/cert \/etc\/openvpn\/ser.crt/' server.conf
sed -i 's/key server.key/key \/etc\/openvpn\/ser.key/' server.conf
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/easy-rsa/keys/clt.ovpn
cd /etc/easy-rsa/keys
sed -i '/ca ca.crt/s/^/#/' clt.ovpn
sed -i '/cert client.crt/s/^/#/' clt.ovpn
sed -i '/key client.key/s/^/#/' clt.ovpn
read -p "Enter the ip address of this machine where openvpn server is: " openvpnip
sed -i "s/remote my-server-1/remote $openvpnip/" clt.ovpn
echo "<ca>" >> clt.ovpn
cat ca.crt >> clt.ovpn
echo "</ca>" >> clt.ovpn
echo "<cert>" >> clt.ovpn
cat clt.crt >> ctl.ovpn
echo "</cert>" >> clt.ovpn
echo "<key>" >> clt.ovpn
cat clt.key >> clt.ovpn
echo "</key>" >> clt.ovpn
echo "leaving directory .."
cd $CURRENT_DIR
echo -e "${RED} now run # openvpn --config /etc/openvpn/server.conf ${NC}"
echo -e "transfer the clt.ovpn to client machine"

