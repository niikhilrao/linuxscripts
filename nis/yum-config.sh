#!/bin/bash


config_yum () {
echo -e "Editing Yum Files"
mount -t auto /dev/sr0 /yum
rm -rf /etc/yum.repos.d/*
echo -e "[cdrom] \nname=cdrom \nbaseurl=file:///yum \nchecked=1 \ngpgcheck=0" > /etc/yum.repos.d/cdrom.repo
}

echo "Configuring YUM Requirment is Centos 7 with server GUI"
$(mkdir /yum)
if mount | grep sr0; then
	echo "Centos 7 CD rom Found Mounting Now "
	config_yum
else 
	echo -e "\n Hey You haven't connected Cd-Rom Go -> Vmnet setting and Connect centos 7 CDRom and try again"
	exit 0
fi
