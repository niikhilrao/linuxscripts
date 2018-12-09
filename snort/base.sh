#!/bin/bash

apt-get install apache2 php5 p7zip libapache2-mod-php5 php5-mcrypt php5-mysqlnd libphp-adodb php-pear -y
pear install mail Net_SMTP Auth_SASL mail_mime
cd /snortemp
wget ftp://192.168.74.41/snort/base-1.4.5.tar.gz
tar -zxvf base-1.4.5.tar.gz
 cd base-1.4.5/
mkdir /var/www/html/base
 mv * /var/www/html/base/
chown -R www-data:www-data /var/www/html/base
$(sed -i 's/error_reporting\s=\s.*/error_reporting = E_ALL \& \~E_NOTICE/' /etc/php5/apache2/php.ini)
service apache2 restart





