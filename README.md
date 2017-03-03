# Automation_NTI-310

1) Server scripts are run on CentOS

2) Client scripts are run on Ubuntu

3) Use utility scripts as needed. NFS takes an IP as an argument. Python ldif creator is interactive.

4) Domain and admin account name are both hardcoded in the LDAP Server install documents. This may change.

Spin-up process:
create-new-instance.py from cloud enabled device
Python script passes in advanced installer with metadata
Advanced installer calls subsequent scripts modularly

# No warranty is implied or given. Use at your own risk and your milage may vary.
