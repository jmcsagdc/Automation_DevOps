# Automation_NTI-310

1) Server scripts are run on CentOS by automation

2) Client scripts are run on Ubuntu by automation

3) Use utility scripts as needed. Python ldif creator is interactive.

4) Domain and admin account name are both hardcoded in the LDAP Server install documents. This may change.

Spin-up process:

create-full-network-nocloud.py from cloud enabled device

Python script passes in advanced installer from generated file and with metadata

Pre-install.sh runs

Pre-install's last step is to run machine-helper which runs subsequent scripts modularly

# No warranty is implied or given. Use at your own risk and your milage may vary.
