#!/bin/bash

echo -e " \t Welcome to static IP configuration \t"
read -p "Please Enter the static ip that you want to assign " staticip
read -p "Please Enter the Gateway ip that you wannt to assign " gatewayip
read -p "Please Enter the Dns ip that you want " dnsip
sed -i '/iface eth0 /s/^/#/' /etc/network/interfaces
echo -e "iface eth0 inet static\n\taddress $staticip\n\tnetmask 255.255.255.0\n\tgateway $gatewayip\n\tdns-nameservers $dnsip 8.8.8.8" >> /etc/network/interfaces
init 6