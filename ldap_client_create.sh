myKernel=$(uname -r | grep 'generic')

echo 'myKernel is ' $myKernel

if uname -r | grep 'generic' 1>/dev/null
then
  echo "Ubuntu is correct for server"
  #echo "Wrong OS" # If Ubuntu is NOT target OS
  #exit 1
else
  echo "Wrong OS" # If redhat is NOT target
  exit 1
fi

# Install the openldap client stuff

echo "Go non-interactive for install"
export DEBIAN_FRONTEND=noninteractive
apt-get --yes install libpam-ldap nscd
unset DEBIAN_FRONTEND
cp /etc/ldap.conf /etc/ldap.conf.orig
# Edit ldap.conf
perl -pi -e 's|base dc=example,dc=net|base dc=jmcsagdc,dc=local|g' /etc/ldap.conf

perl -pi -e 's|uri ldapi:///|uri ldap://aggserver7|g' /etc/ldap.conf

perl -pi -e 's|rootbinddn cn=manager,dc=example,dc=net|#rootbinddn cn=manager,dc=example,dc=net|g' /etc/ldap.conf

# The following comments show defaaults at time of writing. We want these.
## Do not hash the password at all; presume
## the directory server will do it, if
## necessary. This is the default.
#pam_password md5

## The LDAP version to use (defaults to 3
## if supported by client library)
#ldap_version 3

echo "Configure nsswitch.conf"
sed -i 's,passwd:         compat,passwd:         ldap compat,g' /etc/nsswitch.conf
sed -i 's,group:          compat,group:          ldap compat,g' /etc/nsswitch.conf
sed -i 's,shadow:         compat,shadow:         ldap compat,g' /etc/nsswitch.conf

echo "Configure pam.d"
#add this line to the bottom of the config file
sed -i '$ a\session required    pam_mkhomedir.so skel=/etc/skel umask=0022' /etc/pam.d/common-session

# Restart the LDAP client service.
echo "Restart nscd"
/etc/init.d/nscd restart # Ubuntu
