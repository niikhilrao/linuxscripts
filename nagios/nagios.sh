#!/bin/bash

CURRENT_DIR=$(pwd)
MASK='s'
RED='\033[0;31m'
NC='\033[0m'

echo -e "deb\tftp://192.168.74.41/debian/\tjessie\tmain" > /etc/apt/sources.list
apt-get update 
apt-get install -y autoconf gcc libc6 make wget unzip nginx php5-fpm libgd2-xpm-dev build-essential spawn-fcgi fcgiwrap apache2-utils tree dos2unix
mkdir /dl
cd /dl
wget https://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.2.tar.gz
wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-3.2.1/nrpe-3.2.1.tar.gz
tar -zxvf nagios-4.4.2.tar.gz
tar -zxvf nagios-plugins-2.2.1.tar.gz
tar -zxvf nrpe-3.2.1.tar.gz

cd nagios-4.4.2/
./configure --with-httpd-conf=/etc/nginx/sites-enabled
make all
make install-groups-users
usermod -a -G nagios www-data
make install
make install-daemoninit
make install-commandmode
make install-config
#make install-webconf
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
#iptables -I INPUT -p tcp --destination-port 80 -j ACCEPT
#apt-get install -y iptables-persistent
cd $CURRENT_DIR
cp nagios.conf /etc/nginx/sites-enabled/
URL_PATH_LINE=$(awk '/url_html_path/{print NR}' /usr/local/nagios/etc/cgi.cfg)
rm /etc/nginx/sites-available/default
$(sed -i "$URL_PATH_LINE$MASK/.*/url_html_path=\//" /usr/local/nagios/etc/cgi.cfg)
systemctl restart nagios
systemctl restart nginx 
apt-get install -y autoconf gcc libc6 libmcrypt-dev make libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext
cd /dl/nagios-plugins-2.2.1/
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
make 
make install
cd /dl/nrpe-3.2.1/
./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
make all
make install
cp sample-config/nrpe.cfg /usr/local/nagios/etc/
ALLOWED_HOST_LINE=$(awk '/allowed_hosts/{print NR}' /usr/local/nagios/etc/nrpe.cfg)
$(sed -i "$ALLOWED_HOST_LINE$MASK/.*/allowed_hosts=127.0.0.1,::1,192.168.0.0\/16/" /usr/local/nagios/etc/nrpe.cfg)
/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d
/usr/local/nagios/libexec/check_nrpe -H $(hostname -I)
mkdir /usr/local/nagios/etc/servers
$(sed -i '/^#cfg_dir.*servers$/s/^#//' /usr/local/nagios/etc/nagios.cfg)
echo -e 'define command { \n command_name check_nrpe \n command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ \n }' >> /usr/local/nagios/etc/objects/commands.cfg 
echo -e "${RED} Hey Please setup your remote machine For monitoring "
read -p "Please Enter the ip address of the client to monitoring" ipclient
cp $CURRENT_DIR/debian1.cfg /usr/local/nagios/etc/servers/debian1.cfg
sed -i "s/<ip-address>/$ipclient/" /usr/local/nagios/etc/servers/debian1.cfg
echo -e "${NC}"
systemctl restart nagios
systemctl restart nginx
