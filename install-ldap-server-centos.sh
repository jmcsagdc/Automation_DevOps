#!/bin/bash
sleep 5
myKernel=$(uname -r | grep 'generic')

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

# Must run as root, so check for root and exit if not

if [[ $EUID -ne 0 ]]; then
        echo "This script must be run by the root user" 1>&2
        exit 1
fi

# install ldap
echo "LDAP installation..."
echo "Install openldap-servers"
yum -y install openldap-servers
echo "Install openldap-clients"
yum -y install openldap-clients

# copy db config, change ownership
echo "LDAP configuration..."
echo "Copy config file"
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
echo "Change config ownership"
chown ldap /var/lib/ldap/DB_CONFIG

# enable and start ldap

echo "Enable slapd to start on boot"
systemctl enable slapd
echo "Start the slapd service"
systemctl start slapd
ps awxf | grep slapd

# install apache

echo "Installing apache..."
yum -y install httpd

#enable and start apache

echo "Enable httpd to start on boot"
systemctl enable httpd
echo "Start the httpd service"
systemctl start httpd
ps awxf | grep httpd

#install phpldapadmin
echo "phpLDAPadmin installation"
echo "Install the epel-release repo..."
yum install -y epel-release

echo "Install phpldapadmin..."
yum install -y phpldapadmin

#allow http connection to ldap

echo "SELinux - Allow ldap to use httpd..."
/usr/sbin/getsebool -a | grep httpd_can_connect_ldap # Before change
setsebool -P httpd_can_connect_ldap on
/usr/sbin/getsebool -a | grep httpd_can_connect_ldap # After
sleep 5

#generate new hashed password for db.ldif and store it on the server
newsecret=$(slappasswd -g)
newhash=$(slappasswd -s "$newsecret")
echo -n "$newsecret" > /root/ldap_admin_pass
echo "ldap admin password in /root"

# Make the ldap root user password visible only to system root user
chmod 600 /root/ldap_admin_pass

###################################################################################################################
#copy db.ldif and add to config

echo "Create db.ldif"

echo "dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=jmcsagdc,dc=local

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=ldapadm,dc=jmcsagdc,dc=local

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: $newhash" >> /etc/openldap/slapd.d/db.ldif

echo "Use the db.ldif for ldap configuration"
ldapmodify -Y EXTERNAL  -H ldapi:/// -f /etc/openldap/slapd.d/db.ldif
sleep 5

# Make monitor.ldif and add to config
echo "Making monitor.ldif"
echo "dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base=\"gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth\" read by dn.base=\"cn=ldapadm,dc=jmcsagdc,dc=local\" read by * none" > /etc/openldap/slapd.d/monitor.ldif

echo "Change monitor.ldif ownership" # Seems this is the only one we do this with
chown ldap. /etc/openldap/slapd.d/monitor.ldif

echo "Use monitor.ldif for ldap configuration"
ldapmodify -Y EXTERNAL  -H ldapi:/// -f /etc/openldap/slapd.d/monitor.ldif
sleep 5

# Create ssl cert

echo "Creating LDAP's self-signed ssl certificate...."
openssl req -new -x509 -nodes -out /etc/openldap/certs/jmcsagdcldapcert.pem -keyout /etc/openldap/certs/jmcsagdcldapkey.pem -days 365 -subj "/C=US/ST=WA/L=Seattle/O=IT/OU=NTI310IT/CN=
jmcsagdc.local"
echo "Key and Cert created in /etc/openldap/certs..."

# Change ownership of certs and verify

echo "Change ownership of cert"
chown -R ldap. /etc/openldap/certs/*.pem

# Create cert.ldif
echo "dn: cn=config
changetype: modify
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/openldap/certs/jmcsagdcldapcert.pem

dn: cn=config
changetype: modify
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/openldap/certs/jmcsagdcldapkey.pem" >> /etc/openldap/slapd.d/certs.ldif

echo "Add cert.ldif to ldap configuration..."
ldapmodify -Y EXTERNAL  -H ldapi:/// -f /etc/openldap/slapd.d/certs.ldif

#add the cosine and nis LDAP schemas

echo "Adding the cosine and nis schemas..."
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

#create base.ldif file for domain
echo "Creating base.ldif"
echo "dn: dc=jmcsagdc,dc=local
dc: jmcsagdc
objectClass: top
objectClass: domain

dn: cn=ldapadm,dc=jmcsagdc,dc=local
objectClass: organizationalRole
cn: ldapadm
description: LDAP Manager

dn: ou=People,dc=jmcsagdc,dc=local
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=jmcsagdc,dc=local
objectClass: organizationalUnit
ou: Group" >> /etc/openldap/slapd.d/base.ldif

echo "Add base.ldif to ldap configuration..."
ldapadd -x -D "cn=ldapadm,dc=jmcsagdc,dc=local" -f /etc/openldap/slapd.d/base.ldif -y /root/ldap_admin_pass

# phpLDAPadmin
##############################################################################################################################
#
# Search and replace lines in /etc/phpldapadmin/config.php
#
#### // $servers->setValue('server','port',389); #Uncomment
#### $servers->setValue('server','port',389);
#
#### // $servers->setValue('login','attr','dn'); #Uncomment
#### $servers->setValue('login','attr','dn');
#
#### $servers->setValue('login','attr','uid'); # Comment out
#### // $servers->setValue('login','attr','uid');
#
# ## do not usee ## $servers->setValue('server','host','server_domain_name_or_IP_address');
# ## do not usee ## $servers->setValue('server','host','127.0.0.1'); # Line 298 was commented out and 539 is unchanged
#
#### $servers->setValue('server','name','Local LDAP Server'); # Add your UI display name
#### $servers->setValue('server','name','CentOS7 LDAP Test Server');
#
#### // $servers->setValue('server','base',array('')); # Add your domain name components and uncomment
#### $servers->setValue('server','base',array('dc=testdomain,dc=com'));
#
#### // $servers->setValue('login','bind_id',''); # Add your common name and uncomment
#### $servers->setValue('login','bind_id','cn=admin,dc=testdomain,dc=com');
#
#### // $config->custom->appearance['hide_template_warning'] = false; # Hide nonsense error messages
#### $config->custom->appearance['hide_template_warning'] = true;
#
#### // $servers->setValue('login','anon_bind',true);
#### $servers->setValue('login','anon_bind',false);

# First back up to .orig
cp /etc/phpldapadmin/config.php /etc/phpldapadmin/config.php.orig



# Now make the changes
perl -pi -e 's|\x2F\x2F \x24servers\x2D\x3EsetValue\x28\x27login\x27,\x27anon_bind\x27,true\x29\x3B|\x24servers\x2D\x3EsetValue\x28\x27login\x27,\x27anon_bind\x27,false\x29\x3B|g' /etc/phpldapadmin/config.php
perl -pi -e 's|\x2F\x2F \x24config\x2D\x3Ecustom\x2D\x3Eappearance\x5B\x27hide_template_warning\x27\x5D \x3D false\x3B|\x24config\x2D\x3Ecustom\x2D\x3Eappearance\x5B\x27hide_template_warning\x27\x5D \x3D true\x3B|g' /etc/phpldapadmin/config.php
perl -pi -e 's|\x2F\x2F \x24servers\x2D\x3EsetValue\x28\x27login\x27,\x27bind_id\x27,\x27\x27\x29\x3B|\x24servers\x2D\x3EsetValue\x28\x27login\x27,\x27bind_id\x27,\x27cn\x3Dldapadm,dc\x3Djmcsagdc,dc\x3Dlocal\x27\x29\x3B|g' /etc/phpldapadmin/config.php
perl -pi -e 's|\x2F\x2F \x24servers\x2D\x3EsetValue\x28\x27server\x27,\x27base\x27,array\x28\x27\x27\x29\x29\x3B|\x24servers\x2D\x3EsetValue\x28\x27server\x27,\x27base\x27,array\x28\x27dc\x3Djmcsagdc,dc\x3Dlocal\x27\x29\x29\x3B|g' /etc/phpldapadmin/config.php
perl -pi -e 's|\x24servers\x2D\x3EsetValue\x28\x27server\x27,\x27name\x27,\x27Local LDAP Server\x27\x29\x3B|\x24servers\x2D\x3EsetValue\x28\x27server\x27,\x27name\x27,\x27CentOS7 LDAP Test Server\x27\x29\x3B|g' /etc/phpldapadmin/config.php
perl -pi -e 's|\x24servers\x2D\x3EsetValue\x28\x27login\x27,\x27attr\x27,\x27uid\x27\x29\x3B|\x2F\x2F \x24servers\x2D\x3EsetValue\x28\x27login\x27,\x27attr\x27,\x27uid\x27\x29\x3B|g' /etc/phpldapadmin/config.php
perl -pi -e 's|\x2F\x2F \x24servers\x2D\x3EsetValue\x28\x27login\x27,\x27attr\x27,\x27dn\x27\x29\x3B|\x24servers\x2D\x3EsetValue\x28\x27login\x27,\x27attr\x27,\x27dn\x27\x29\x3B|g' /etc/phpldapadmin/config.php
perl -pi -e 's|\x2F\x2F \x24servers\x2D\x3EsetValue\x28\x27server\x27,\x27port\x27,389\x29\x3B|\x24servers\x2D\x3EsetValue\x28\x27server\x27,\x27port\x27,389\x29\x3B|g' /etc/phpldapadmin/config.php


# 
# OPTIONAL SECURITY
# # mkdir /etc/apache2/ssl
# # openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt

echo "######################"
# Change to allow login from the web

echo "Rename phpldapadmin.conf to orig and re-create"
mv /etc/httpd/conf.d/phpldapadmin.conf /etc/httpd/conf.d/phpldapadmin.conf.orig
echo "#
#  Web-based tool for managing LDAP servers
#

Alias /phpldapadmin /usr/share/phpldapadmin/htdocs
Alias /ldapadmin /usr/share/phpldapadmin/htdocs

<Directory /usr/share/phpldapadmin/htdocs>
  <IfModule mod_authz_core.c>
    # Apache 2.4
    # Require local
    Require all granted
  </IfModule>
  <IfModule !mod_authz_core.c>
    # Apache 2.2
    Order Deny,Allow
    Deny from all
    Allow from 127.0.0.1
    Allow from ::1
  </IfModule>
</Directory>
" >> /etc/httpd/conf.d/phpldapadmin.conf

#restart htttpd, slapd services

echo "Restarting httpd and slapd services..."
systemctl restart httpd
ps awxf | grep httpd
echo "######################"
systemctl restart slapd
ps awxf | grep slapd
echo "######################"

sleep 5
#configure firewall to allow access

echo "Configuring the built-in firewall to allow access..."
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --reload

echo "ldap configuration complete. Point your browser to http://<serverIPaddress>/phpldapadmin to login..."
echo "************************** NOT HARDENING **************************" >> /root/INSTALL.LOG
echo "If you want, run /root/Automation/utility-adjust-harden-centos.sh"  >> /root/INSTALL.LOG
#/root/Automation/utility-adjust-harden-centos.sh >> /root/INSTALL.LOG
