#!/bin/bash
CURRENT_DIR=$(pwd)
MASK='s'
RED='\033[0;31m'
NC='\033[0m'
echo -e "${RED} Enter the ip address of your local machine ${NC}"
read LOCALIP
echo -e "deb\tftp://$LOCALIP/debian\tjessie\tmain" > /etc/apt/sources.list
apt-get update
mkdir /snortemp
cd /snortemp
apt-get install bison flex libpcap-dev libpcre3-dev libdumbnet-dev build-essential zlib1g-dev liblzma-dev openssl libssl-dev 
wget ftp://$LOCALIP/snort/snort-2.9.12.tar.gz
wget ftp://$LOCALIP/snort/daq-2.0.6.tar.gz
wget ftp://$LOCALIP/snort/LuaJIT-2.0.5.tar.gz
tar -zxvf snort-2.9.12.tar.gz
tar -zxvf daq-2.0.6.tar.gz
tar -zxvf LuaJIT-2.0.5.tar.gz
cd daq-2.0.6/
./configure
make 
make install
cd ../LuaJIT-2.0.5/
make 
make install
cd ../snort-2.9.12/
./configure --enable-sourcefire
make
make install
mkdir /etc/snort
mkdir /etc/snort/rules
mkdir /etc/snort/preproc_rules
mkdir /var/log/snort
mkdir /usr/local/lib/snort_dynamicrules
groupadd snort
useradd -r -s /usr/bin/nologin -c SNORT_IDS -g snort snort
touch /etc/snort/rules/black_list.rules
touch /etc/snort/rules/white_list.rules
touch /etc/snort/rules/local.rules

chmod -R 5775 /etc/snort
chmod -R 5775 /var/log/snort
chmod -R 5775 /usr/local/lib/snort_dynamicrules/
chown -R snort:snort /etc/snort
chown -R snort:snort /var/log/snort
chown -R snort:snort /usr/local/lib/snort_dynamicrules

cp etc/*.map /etc/snort
cp etc/*.conf* /etc/snort
cp etc/*.dtd /etc/snort
ldconfig
