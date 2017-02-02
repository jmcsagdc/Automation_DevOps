# Install the openldap client stuff

# yum install -y openldap-clients nss-pam-ldapd # CentOS
sudo apt-get install ldap-auth-client nscd # Ubuntu

# Add the client machine to LDAP server for SSO.

authconfig --enableldap --enableldapauth --ldapserver=centos7-ldap-test --ldapbasedn="dc=jmcsagdc,dc=local" --enablemkhomedir --update

# Restart the LDAP client service.

# systemctl restart  nslcd # centos
/etc/init.d/nscd restart # Ubuntu
