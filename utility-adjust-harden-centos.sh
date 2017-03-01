myKernel=$(uname -r | grep 'generic')
sleep 5
echo 'myKernel is ' $myKernel

if uname -r | grep 'generic' 1>/dev/null
then
  echo "Wrong OS" # If Ubuntu is NOT target OS
  exit 1
else
  echo "CentOS is correct for server"
  #echo "Wrong OS" # If redhat is NOT target
  #exit 1
fi

# Get global IP
echo "Getting global IP"
testglobalip=`curl -A '"Mozilla/4.0"' 91.198.22.70`
echo "TESTGLOBALIP results: $testglobalip"

myglobalip=`echo $testglobalip | awk '{print $NF}' | awk -F'<' '{print $1}'`

echo "myglobalip = $myglobalip"

myhostname=`hostname`

echo "myhostname= $myhostname"
sleep 5
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
-subj "/C=US/ST=WA/L=Seattle/O=IT/OU=NTI310IT/CN=$myhostname"

echo "Creating DH group"
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
cat /etc/ssl/certs/dhparam.pem | tee -a /etc/ssl/certs/apache-selfsigned.crt

echo "Here is your cert: "
openssl x509 -in /etc/ssl/certs/apache-selfsigned.crt -noout -text

# Webserver changes for LDAP https port and aliases
echo "Modify /etc/httpd.conf.d/ssl.conf to point to 443"
#
perl -pi -e "s|<VirtualHost _default_:443>|<VirtualHost _default_:443>

Alias /phpldapadmin /usr/share/phpldapadmin/htdocs
Alias /ldapadmin /usr/share/phpldapadmin/htdocs
DocumentRoot \x22/usr/share/phpldapadmin/htdocs\x22
ServerName $myhostname:443|g" /etc/httpd/conf.d/ssl.conf

perl -pi -e "s|SSLProtocol all -SSLv2|# SSLProtocol all -SSLv2|g" /etc/httpd/conf.d/ssl.conf
perl -pi -e "s|SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5:!SEED:!IDEA|# SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5:!SEED:!IDEA|g" /etc/httpd/conf.d/ssl.conf
perl -pi -e 's|</VirtualHost>|</VirtualHost>

# Begin copied text
# from https://cipherli.st/
# and https://raymii.org/s/tutorials/Strong_SSL_Security_On_Apache2.html

SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH
SSLProtocol All -SSLv2 -SSLv3
SSLHonorCipherOrder On
# Disable preloading HSTS for now.  You can use the commented out header line that includes
# the "preload" directive if you understand the implications.
#Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains; preload"
Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains"
Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff
# Requires Apache >= 2.4
SSLCompression off
SSLUseStapling on
SSLStaplingCache "shmcb:logs/stapling-cache(150000)"
# Requires Apache >= 2.4.11
# SSLSessionTickets Off
|g'  /etc/httpd/conf.d/ssl.conf

# No anonymous login for LDAP
# (Should be installed this way. This makes sure.)
perl -pi -e 's|\x2F\x2F \x24servers\x2D\x3EsetValue\x28\x27login\x27,\x27anon_bind\x27,true\x29\x3B|\x24servers\x2D\x3EsetValue\x28\x27login\x27,\x27anon_bind\x27,false\x29\x3B|g' /etc/phpldapadmin/config.php

# Add ldaps:///
sed -i 's/SLAPD_URLS="ldapi:\/\/\/ ldap:\/\/\/"/SLAPD_URLS=\"ldapi:\/\/\/ ldap:\/\/\/ ldaps:\/\/\/"/g' /etc/sysconfig/slapd

# Restart slapd
systemctl restart slapd

# Point at apache cert and key for httpd
perl -pi -e 's|SSLCertificateFile /etc/pki/tls/certs/localhost.crt|#SSLCertificateFile /etc/pki/tls/certs/localhost.crt
SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt|g' /etc/httpd/conf.d/ssl.conf

perl -pi -e 's|SSLCertificateKeyFile /etc/pki/tls/private/localhost.key|#SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key|g' /etc/httpd/conf.d/ssl.conf

perl -pi -e 's|</Directory>|</Directory>
SSLEngine on
SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key|g' /etc/httpd/conf.d/phpldapadmin.conf

# Restart httpd to pick up changes
systemctl restart  httpd.service

echo "curl your server:"
curl -vvI https://`hostname`

# Ports for NFS (if applicable)

# 
