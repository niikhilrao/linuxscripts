#!/bin/bash

CURRENT_DIR=$(pwd)
MASK='s'
RED='\033[0;31m'
NC='\033[0m'

$(sed -i '/^#cfg_file.*windows.cfg$/s/^#//' /usr/local/nagios/etc/nagios.cfg)
echo -e "${RED} Pleasew enter the ip address of the windows client to be monitored"
read -p "Ip address " ipwin
$(sed -i "s/192.168.1.2/$ipwin/" /usr/local/nagios/etc/objects/windows.cfg)
$(sed -i 's/.*\/check_nt.*/    command_line  \$USER1\$\/check_nt -H \$HOSTADDRESS\$ -s nikhil -p 12489 -v \$ARG1\$ \$ARG2\$/' /usr/local/nagios/etc/objects/commands.cfg)
systemctl restart nagios
