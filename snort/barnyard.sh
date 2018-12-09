#!/bin/bash

CURRENT_DIR=$(pwd)
MASK='s'
RED='\033[0;31m'
NC='\033[0m'
echo -e "${RED} Enter the ip address of your local machine ${NC}"
read LOCALIP
echo -e "deb\tftp://$LOCALIP/maria_db/debian/8.6.0/amd64/\t/" >> /etc/apt/sources.list
apt-get update
apt-get install mariadb-server mariadb-client libmariadbclient18 libmariadbd-dev libmariadbclient-dev autoconf libtool dos2unix unzip --force-yes -y
echo "Changing dir"
cd /snortemp
wget ftp://$LOCALIP/snort/barnyard2-2-1.13.tar.gz
tar -zxvf barnyard2-2-1.13.tar.gz
cd barnyard2-2-1.13/
ln -s /usr/include/dumbnet.h /usr/include/dnet.h
./autogen.sh
./configure --with-mysql --with-mysql-libraries=/usr/lib
make
make install
cp etc/barnyard2.conf /etc/snort/
mkdir /var/log/barnyard2
chown snort:snort /var/log/barnyard2
touch /var/log/snort/barnyard2.waldo
chown snort:snort /var/log/snort/barnyard2.waldo
mysql -e "create database snort" -ptoor
mysql -e "create user 'snort'@'localhost' identified by 'toor'" -ptoor
mysql -e "grant select,update,create,delete,insert on snort.* to 'snort'@'localhost'" -ptoor
mysql -uroot -ptoor snort < schemas/create_mysql
cd ../
wget ftp://192.168.74.41/snort/create-sidmap.pl
dos2unix create-sidmap.pl
chmod +x create-sidmap.pl
./create-sidmap.pl /etc/snort/rules > /etc/snort/sid-msg.map
barnyard2 -u snort -g snort -c /etc/snort/barnyard2.conf -f snort.u2 -w /var/log/snort/barnyard2.waldo -d /var/log/snort

