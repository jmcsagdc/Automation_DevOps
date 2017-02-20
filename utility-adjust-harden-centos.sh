# Get global IP
echo "Getting global IP"
testglobalip=`curl -A '"Mozilla/4.0"' 91.198.22.70`
echo "TESTGLOBALIP results: $testglobalip"

myglobalip=`echo $testglobalip | awk '{print $NF}' | awk -F'<' '{print $1}'`

echo "myglobalip = $myglobalip"

# First the local permissions
echo "Back up sudoers"
cp /etc/sudoers /etc/sudoers.orig
echo "Only adm members get sudo..."
perl -pi -e 's|## Allows people in group wheel to run all commands|## Allows people in group adm to run all commands|g' /etc/sudoers
perl -pi -e 's|\x25wheel|\x25adm|g' /etc/sudoers

# Disallow SSH for regions outside US

# Disallow passworded logins for SSH on servers

# Firewall

# Ports for LDAP (if applicable)

# LDAP users password aging

# https for LDAP
echo "Adding epel repo from FedoraProject.org"
su -c 'rpm -Uvh http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm'

echo "Installing headless entropy generator"
yum install -y haveged

echo "Enable haveged start on boot"
chkconfig haveged on

echo "Starting haveged entropy generator"
systemctl start haveged.service
systemctl status haveged.service

echo "Adding randomness testing tools"
yum install -y rng-tools

echo "The following command should show 998+ successes and a few failures. This is OK."
cat /dev/random | rngtest -c 1000

echo "This shows the entropy pool. Anything over 1000 is good and will replentish automatically"
cat /proc/sys/kernel/random/entropy_avail

# Install mod_ssl
echo "Installing mod_ssl"
yum install -y mod_ssl

echo "Creating and setting perms for /etc/ssl/private"
mkdir /etc/ssl/private
chmod 700 /etc/ssl/private

echo "This part is for Diffie-Hellman. It can take 5 minutes."
echo "Current server time: `date`"

echo "Creating SSL key and Certificate via openssl"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/apache-selfsigned.key -out \
/etc/ssl/certs/apache-selfsigned.crt \
-subj "/C=US/ST=WA/L=Seattle/O=IT/OU=NTI310IT/CN=$myglobalip"
#TODO Fix this option string. Right now it doesn't get picked up.
echo "Creating DH group"
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
cat /etc/ssl/certs/dhparam.pem | tee -a /etc/ssl/certs/apache-selfsigned.crt

# Webserver changes for LDAP https port and aliases
echo "Modify /etc/httpd.conf.d/ssl.conf to point to 443"
#
perl -pi -e "s|<VirtualHost _default_:443>|<VirtualHost _default_:443>

Alias /phpldapadmin /usr/share/phpldapadmin/htdocs
Alias /ldapadmin /usr/share/phpldapadmin/htdocs
DocumentRoot \x22/usr/share/phpldapadmin/htdocs\x22
ServerName $myglobalip:443|g" /etc/httpd/conf.d/ssl.conf

# No anonymous login for LDAP
# (Should be installed this way. This makes sure.)
perl -pi -e 's|\x2F\x2F \x24servers\x2D\x3EsetValue\x28\x27login\x27,\x27anon_bind\x27,true\x29\x3B|\x24servers\x2D\x3EsetValue\x28\x27login\x27,\x27anon_bind\x27,false\x29\x3B|g' /etc/phpldapadmin/config.php

# Ports for NFS (if applicable)

# 
