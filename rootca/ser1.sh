#!/bin/bash
CURRENT_DIR=$(pwd)
MASK='s'
RED='\033[0;31m'
NC='\033[0m'
echo -e "${RED} Enter the domain name example: rao.com or hackme.local ${NC}"
read DOMIANNAME
echo -e "${RED} \t Now Configuring ssh Please Please <Enter> key only  ${NC}"
ssh-keygen -q
echo -e "Please Provide the subca machine password for easy config"
ssh-copy-id root@subca
mkdir serv
cd serv
cp $CURRENT_DIR/subca.cnf .
dos2unix subca.cnf
openssl genrsa -out www.$DOMIANNAME.key
chmod 400 www.$DOMIANNAME.key
echo -e "${RED} Please enter the Fully qualified Domain name ${NC} "
openssl req -config subca.cnf -key www.$DOMIANNAME.key -new -sha256 -out www.$DOMIANNAME.csr.pem
scp www.$DOMIANNAME.csr.pem root@subca:/root/subca/csr
ssh root@subca "openssl ca -config /root/subca/subca.cnf -extensions server_cert -days 365 -notext -md sha256 -in /root/subca/csr/www.$DOMIANNAME.csr.pem -out /root/subca/certs/www.$DOMIANNAME.cert.pem"
ssh root@subca << EOF
chmod 444 /root/subca/certs/www.$DOMIANNAME.cert.pem
exit
EOF
scp root@subca:/root/subca/certs/{www.$DOMIANNAME.cert.pem,ca-chain.cert.pem} .
mkdir /etc/apache2/ssl
cp ca-chain.cert.pem /etc/apache2/ssl/
cp www.$DOMIANNAME.cert.pem /etc/apache2/ssl/
cp www.$DOMIANNAME.key /etc/apache2/ssl/
chmod 600 /etc/apache2/ssl/*
a2enmod ssl
a2ensite default-ssl.conf
sed -i "4s/.*/\t\tServerName www.$DOMIANNAME/" /etc/apache2/sites-enabled/default-ssl.conf
sed -i "s/SSLCertificateFile.*/SSLCertificateFile \/etc\/apache2\/ssl\/www.$DOMIANNAME.cert.pem/" /etc/apache2/sites-enabled/default-ssl.conf
sed -i "s/SSLCertificateKeyFile.*/SSLCertificateKeyFile \/etc\/apache2\/ssl\/www.$DOMIANNAME.key/" /etc/apache2/sites-enabled/default-ssl.conf
sed -i "s/SSLCertificateChainFile.*/SSLCertificateChainFile \/etc\/apache2\/ssl\/ca-chain.cert.pem/" /etc/apache2/sites-enabled/default-ssl.conf
sed -i 's/#SSLCertificateChainFile/SSLCertificateChainFile/' /etc/apache2/sites-enabled/default-ssl.conf
systemctl start apache2
systemctl restart apache2