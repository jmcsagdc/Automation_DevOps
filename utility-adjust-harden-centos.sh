# First the local permissions
echo "Back up sudoers"
cp /etc/sudoers /etc/sudoers.orig
echo "Only adm members get sudo..."
perl -pi -e 's|## Allows people in group wheel to run all commands|## Allows people in group adm to run all commands|g' /etc/sudoers
perl -pi -e 's|%wheel    ALL=(ALL)       ALL|%adm    ALL=(ALL)       ALL|g' /etc/sudoers

# Disallow SSH for regions outside US

# Disallow passworded logins for SSH on servers

# Firewall

# Ports for LDAP (if applicable)

# LDAP users password aging

# https for LDAP

# No anonymous login for LDAP

# Ports for NFS (if applicable)

# 
