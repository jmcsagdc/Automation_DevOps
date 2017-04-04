#!/bin/bash

# Install nagios server instance

# Prereqs:
echo "yum installing gcc glibc glibc-common gd gd-devel make net-snmp openssl-devel xinetd unzip"
yum install -y gcc glibc glibc-common gd \
               gd-devel make net-snmp openssl-devel xinetd unzip
# PHP
echo "installing php"
yum -y install php

# Apache

echo "Installing apache..."
yum -y install httpd

#enable and start apache

echo "Enable httpd to start on boot"
systemctl enable httpd
echo "Start the httpd service"
systemctl start httpd
ps awxf | grep httpd

# Add user and group for nagios
echo "Adding user for nagios, group for nagcmd"
useradd nagios
groupadd nagcmd
usermod -a -G nagcmd nagios

# Install nagios
echo "curl the 4.2.0 nagios tarball"
cd ~
curl -L -O https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.2.0.tar.gz
echo "untar nagios tarball"
tar xvzf nagios-*.tar.gz

echo "cd into the build directory, configure and make...this may be slow"
cd nagios-4.2.0

./configure --with-command-group=nagcmd

make all
make install
make install-commandmode
make install-init
make install-config
make install-webconf

# configs:
# bin/install -c -m 775 -o nagios -g nagios -d /usr/local/nagios/etc
# /bin/install -c -m 775 -o nagios -g nagios -d /usr/local/nagios/etc/objects
# /bin/install -c -b -m 664 -o nagios -g nagios sample-config/nagios.cfg /usr/local/nagios/etc/nagios.cfg
# /bin/install -c -b -m 664 -o nagios -g nagios sample-config/cgi.cfg /usr/local/nagios/etc/cgi.cfg
# /bin/install -c -b -m 660 -o nagios -g nagios sample-config/resource.cfg /usr/local/nagios/etc/resource.cfg
# /bin/install -c -b -m 664 -o nagios -g nagios sample-config/template-object/templates.cfg /usr/local/nagios/etc/objects/templates.cfg
# /bin/install -c -b -m 664 -o nagios -g nagios sample-config/template-object/commands.cfg /usr/local/nagios/etc/objects/commands.cfg
# /bin/install -c -b -m 664 -o nagios -g nagios sample-config/template-object/contacts.cfg /usr/local/nagios/etc/objects/contacts.cfg
# /bin/install -c -b -m 664 -o nagios -g nagios sample-config/template-object/timeperiods.cfg /usr/local/nagios/etc/objects/timeperiods.cfg
# /bin/install -c -b -m 664 -o nagios -g nagios sample-config/template-object/localhost.cfg /usr/local/nagios/etc/objects/localhost.cfg
# /bin/install -c -b -m 664 -o nagios -g nagios sample-config/template-object/windows.cfg /usr/local/nagios/etc/objects/windows.cfg
# /bin/install -c -b -m 664 -o nagios -g nagios sample-config/template-object/printer.cfg /usr/local/nagios/etc/objects/printer.cfg
# /bin/install -c -b -m 664 -o nagios -g nagios sample-config/template-object/switch.cfg /usr/local/nagios/etc/objects/switch.cfg


# Apache add to nagios

usermod -G nagcmd apache

# Get and install plugins
echo "curl the plugins tarball"
cd ~
curl -L -O http://nagios-plugins.org/download/nagios-plugins-2.2.0.tar.gz
echo "untar the tarball"
tar -xvzf nagios-plugins-2.2.0.tar.gz 
cd nagios-plugins-2.2.0
echo "configure, make and install plugins"
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
make
make install

# get NRPE
echo "curl 2.15 NRPE from sourceforge"
cd ~
curl -L -O http://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz
echo "untar the NRPE"
tar -xvzf nrpe-2.15*
cd nrpe-2.15
echo "configure, make and install NRPE"
./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
make all
make install
make install-xinetd
make install-daemon-config

# configure private IP for nagios server
# Modify only_from line: 
# add private IP address of Nagios server (after 127.0.0.1)

LOCALIP=$(gcloud compute instances describe `hostname` --zone=us-central1-c | grep "networkIP" | awk -F ': ' '{ print $2 }')
echo "back up /etc/xinetd.d/nrpe to .orig"
cp /etc/xinetd.d/nrpe /etc/xinetd.d/nrpe.orig
echo "add in local IP of this server"
perl -pi -e "s|127.0.0.1|127.0.0.1 $LOCALIP|g" /etc/xinetd.d/nrpe

echo "restart xinetd to pick up change"
service xinetd restart

echo "nagios is now installed. moving on to configuration\n\n"
echo "back up /usr/local/nagios/etc/nagios.cfg"
cp /usr/local/nagios/etc/nagios.cfg /usr/local/nagios/etc/nagios.cfg.orig
echo "modifying /usr/local/nagios/etc/nagios.cfg"
perl -pi -e "s|#cfg_dir=/usr/local/nagios/etc/servers|cfg_dir=/usr/local/nagios/etc/servers|g" /usr/local/nagios/etc/nagios.cfg

# create directory to store configuration for each server monitored:

mkdir /usr/local/nagios/etc/servers

echo "back up cp /usr/local/nagios/etc/objects/contacts.cfg to .orig"
cp /usr/local/nagios/etc/objects/contacts.cfg /usr/local/nagios/etc/objects/contacts.cfg.orig

echo "add your email to nagios contacts"
perl -pi -e "s|nagios\x40localhost|jason.vernon\x40seattlecentral.edu|g" /usr/local/nagios/etc/objects/contacts.cfg

echo "back up /usr/local/nagios/etc/objects/commands.cfg to .orig"
cp /usr/local/nagios/etc/objects/commands.cfg /usr/local/nagios/etc/objects/commands.cfg.orig
echo "add in a command to the end of the file"
echo "define command{
        command_name check_nrpe
        command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
        }" >> /usr/local/nagios/etc/objects/commands.cfg

# Apache
echo "configure apache"

htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin Passw0rd
echo "Passw0rd" > /root/nagiosadmin_password
chmod 600 /root/nagiosadmin_password

echo "start nagios and restart httpd"
systemctl start nagios.service
systemctl restart httpd.service

# Enable Nagios to start on boot
chkconfig nagios on
