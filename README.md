# Automation for creating various server networks

1) Server scripts are run on CentOS by automation. Some have modifications you can make inside.

2) Client scripts are run on Ubuntu by automation

3) Use utility scripts as needed. Python ldif creator is interactive. Most are in helpers.py now so you can import them.

4) Domain and admin account name are both hardcoded in the LDAP Server install documents. This may change.

# Spin-up process:

Admin runs 1-XXX.py from cloud enabled device

1-XXX.py creates 2-XXX.py

Python script passes in advanced installer from generated file via metadata

2-XXX.py runs

2-XXX.py's last step is to run 3-XXX.py which runs subsequent scripts modularly

# No warranty is implied or given. Use at your own risk and your milage may vary.
