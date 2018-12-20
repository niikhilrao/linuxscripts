#!/bin/bash
nagios_for_windows() {
$(sed -i '/^#cfg_file.*windows.cfg$/s/^#//' /usr/local/nagios/etc/nagios.cfg)
echo -e "${RED} Pleasew enter the ip address of the windows client to be monitored"
read -p "Ip address " ipwin
read -p "Enter the Password for windows machine to be monitored " PASSWORD
$(sed -i "s/192.168.1.2/$ipwin/" /usr/local/nagios/etc/objects/windows.cfg)
$(sed -i 's/.*\/check_nt.*/    command_line  \$USER1\$\/check_nt -H \$HOSTADDRESS\$ -s $PASSWORD -p 12489 -v \$ARG1\$ \$ARG2\$/' /usr/local/nagios/etc/objects/commands.cfg)
systemctl restart nagios
}
nagios_for_debian() {
mkdir /usr/local/nagios/etc/servers
$(sed -i '/^#cfg_dir.*servers$/s/^#//' /usr/local/nagios/etc/nagios.cfg)
echo -e 'define command { \n command_name check_nrpe \n command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ \n }' >> /usr/local/nagios/etc/objects/commands.cfg 
echo -e "${RED} Hey Please setup your remote machine For monitoring "
read -p "Please Enter the ip address of the client to monitoring" ipclient
cp $CURRENT_DIR/debian1.cfg /usr/local/nagios/etc/servers/debian1.cfg
sed -i "s/<ip-address>/$ipclient/" /usr/local/nagios/etc/servers/debian1.cfg
echo -e "${NC}"
}
nagios_dwn_extract() {
mkdir /dl
cd /dl
wget https://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.2.tar.gz
wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-3.2.1/nrpe-3.2.1.tar.gz
tar -zxvf nagios-4.4.2.tar.gz
tar -zxvf nagios-plugins-2.2.1.tar.gz
tar -zxvf nrpe-3.2.1.tar.gz
}
install_nagios() {
cd /dl/nagios-4.4.2/
./configure --with-httpd-conf=/etc/apache2/sites-enabled
make all
make install-groups-users
usermod -a -G nagios www-data
make install
make install-daemoninit
make install-commandmode
make install-config
make install-webconf
cd $CURRENT_DIR
systemctl restart nagios
}
install_plugins() {
cd /dl/nagios-plugins-2.2.1/
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
make 
make install
}
install_nrpe() {
cd /dl/nrpe-3.2.1/
./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
make all
make install
cp sample-config/nrpe.cfg /usr/local/nagios/etc/
ALLOWED_HOST_LINE=$(awk '/allowed_hosts/{print NR}' /usr/local/nagios/etc/nrpe.cfg)
$(sed -i "$ALLOWED_HOST_LINE$MASK/.*/allowed_hosts=127.0.0.1,::1,192.168.0.0\/16/" /usr/local/nagios/etc/nrpe.cfg)
/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d
/usr/local/nagios/libexec/check_nrpe -H $(hostname -I)
}
configure_with_apache() {
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
a2enmod rewrite
a2enmod cgi
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
systemctl restart nagios
systemctl restart apache2
}
configure_repo() {
read -p "Enter the ip address of the base repo ftp hosted " iprepo
echo -e "deb\tftp://$iprepo/debian/\tjessie\tmain" > /etc/apt/sources.list
apt-get update 
apt-get install -y php5 libapache2-mod-php5 php5-mcrypt php5-cgi php5-gd php5-common php5-curl libmcrypt-dev libssl-dev bc gawk dc snmp libnet-snmp-perl gettext autoconf gcc libc6 make wget unzip php5 libgd2-xpm-dev build-essential apache2 apache2-utils tree dos2unix

}
CURRENT_DIR=$(pwd)
MASK='s'
RED='\033[0;31m'
NC='\033[0m'

echo -e "\t Do You to Configure Your repo and install required apt-get packages answer (y/n) ${NC} "
read ANSWER
if [ "$ANSWER" == 'y' ] 
then 
configure_repo
fi

echo -e "\t Do you want to download the nagios tar files and create dl directory (y/n) ${NC}"
if [ "$ANSWER" == 'y' ]
then
nagios_dwn_extract
fi
echo -e "\t ${RED} Do you want to install and config Nagios and component (y/n) ${NC}"
read ANSWER
if [ "$ANSWER" == 'y' ]
then
echo -e " \t ${RED} Installing Nagios ${NC} "
install_nagios
echo -e " \t ${RED} Installing Nagios PLUGINS ${NC} "
install_plugins
echo -e " \t ${RED} Installing Nagios NRPE ${NC} "
install_nrpe 
fi 

echo -e "\t ${RED} Do you want to Add Debian Client  (y/n) ${NC}"
read ANSWER
if [ "$ANSWER" == 'y' ]
then
nagios_for_debian
fi

echo -e "\t ${RED} Do you want to Add Windows Client  (y/n) ${NC}"
read ANSWER
if [ "$ANSWER" == 'y' ]
then
nagios_for_windows
fi
#iptables -I INPUT -p tcp --destination-port 80 -j ACCEPT
#apt-get install -y iptables-persistent






