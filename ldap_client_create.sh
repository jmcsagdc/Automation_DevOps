# Install the openldap client stuff

sudo apt-get install ldap-auth-client nscd # Ubuntu
export DEBIAN_FRONTEND=noninteractive
apt-get --yes install libpam-ldap nscd
unset DEBIAN_FRONTEND
# Add the client machine to LDAP server for SSO.

authconfig --enableldap --enableldapauth --ldapserver=aggserver7 --ldapbasedn="dc=jmcsagdc,dc=local" --enablemkhomedir --update

sed -i 's,passwd:         compat,passwd:         ldap compat,g' /etc/nsswitch.conf
sed -i 's,group:          compat,group:          ldap compat,g' /etc/nsswitch.conf
sed -i 's,shadow:         compat,shadow:         ldap compat,g' /etc/nsswitch.conf

#add this line to the bottom of the config file
sed -i '$ a\session required    pam_mkhomedir.so skel=/etc/skel umask=0022' /etc/pam.d/common-session

# Restart the LDAP client service.

/etc/init.d/nscd restart # Ubuntu
