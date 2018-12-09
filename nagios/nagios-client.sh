#!/bin/bash

CURRENT_DIR=$(pwd)
MASK='s'
RED='\033[0;31m'
NC='\033[0m'

echo -e "deb\thttp://ftp.us.debian.org/debian/\tjessie\tmain" > /etc/apt/sources.list
apt-get update 
apt-get install -y nagios-plugins nagios-nrpe-server
echo -e "${RED} Hey have you setup your nagios server "
read -p "Please Enter the ip address of the nagios server machine" ipserv
sed -i "s/<ip-address>/$ipserv/" /usr/local/nagios/etc/servers/debian1.cfg
echo -e "${NC}" 
$(sed -i "s/allowed_hosts=127.0.0.1/allowed_hosts=127.0.0.1,$ipserv/" /etc/nagios/nrpe.cfg)
systemctl restart nagios-nrpe-server
echo -e "\t \t NOw Restart the nagios service on your nagios server machine or if not configured for client then configure it up"
