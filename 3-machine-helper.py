import os

cloudAction='instances describe `hostname` '
cloudRegion='--zone=us-central1-c'
getMyType=os.popen('gcloud compute '+cloudAction+cloudRegion).read()

if 'ubuntudesktop' in getMyType:
    print 'Desktop'
    # Client machine
    doInstall=os.popen('echo "*** DESKTOP *** ">> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./utility-adjust-ssh-all-os.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./install-ldap-client-ubuntu.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python create-nfs-client-installer-ubuntu.py')
    doInstall=os.popen('echo "****** USED Python NFS client installer ****************" >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python install-rsyslog-client-50-default-all-os.py')
    doInstall=os.popen('echo "****** USED Python rsyslog client installer ************" >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('echo "*** End Helper *** ">> /root/INSTALL.LOG')
if 'centos7ldap' in getMyType:
    print 'LDAP'
    # LDAP Server
    doInstall=os.popen('echo "*** LDAP *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./install-ldap-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python utility-create-new-ldap-groups.py >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python utility-create-ldap-users-from-file.py >> /root/INSTALL.LOG 2>&1')
    # LDAP hardening in the install script now
    doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python install-syslog-client-all-os.py')
    doInstall=os.popen('./install-nagios-client-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('echo "*** End Helper *** ">> /root/INSTALL.LOG')
if 'centos7nfs' in getMyType:
    print 'NFS'
    # NFS Server
    doInstall=os.popen('echo "*** NFS *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./install-nfs-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    # ./utility-nfs-server-add-client-centos.sh # Change to subnet to do this
    #doInstall=os.popen('touch /root/use-utility-nfs-server-add-client-centos.sh-now')
    #doInstall=os.popen('./create-nfs-client-installer-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python install-syslog-client-all-os.py')
    doInstall=os.popen('./install-nagios-client-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('echo "*** End Helper *** ">> /root/INSTALL.LOG')
if 'centos7sql' in getMyType:
    print 'Postgres'
    # Postgres Server
    doInstall=os.popen('echo "*** POSTGRES *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./install-postgres-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python install-syslog-client-all-os.py')
    doInstall=os.popen('./install-nagios-client-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('echo "*** End Helper *** ">> /root/INSTALL.LOG')
if 'centos7django' in getMyType:
    print 'Django'
    # Django and Apache server
    doInstall=os.popen('echo "*** DJANGO and APACHE *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('source /root/Automation/install-django-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('touch /root/CHANGE-FIREWALL-IN-CLOUD-FOR-PORT-8000')
    doInstall=os.popen('echo "****** CHANGE FIREWALL IN CLOUD FOR PORT 8000 ****************" >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python install-syslog-client-all-os.py')
    doInstall=os.popen('./install-nagios-client-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('echo "*** End Helper *** ">> /root/INSTALL.LOG')
if 'centos7plain' in getMyType:
    print 'PLAIN'
    # Plain Server
    doInstall=os.popen('echo "*** PLAIN *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python install-syslog-client-all-os.py')
    doInstall=os.popen('./install-nagios-client-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('echo "*** End Helper *** ">> /root/INSTALL.LOG')
if 'centos7syslog' in getMyType:
    print 'rsyslog'
    # rsyslog Server
    doInstall=os.popen('echo "*** rsyslog *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./install-syslog-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    # DO DOT add the rsyslog client install here.
    doInstall=os.popen('./install-nagios-client-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('echo "*** End Helper *** ">> /root/INSTALL.LOG')
if 'centos7nagios' in getMyType:
    print 'Nagios'
    # Nagios server
    doInstall=os.popen('echo "*** NAGIOS *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('/root/Automation/install-nagios-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('touch /root/CHANGE-FIREWALL-IN-CLOUD-FOR-PORT-5666')
    doInstall=os.popen('echo "****** CHANGE FIREWALL IN CLOUD FOR PORT 5666 ****************" >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python install-syslog-client-all-os.py')
    doInstall=os.popen('python utility-add-nagios-client-configs.py')
    doInstall=os.popen('echo "*** End Helper *** ">> /root/INSTALL.LOG')
if 'centos7build' in getMyType:
    print 'Build'
    # Build server
    doInstall=os.popen('echo "*** Build *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('/root/Automation/install-build-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python install-syslog-client-all-os.py')
    doInstall=os.popen('echo "*** End Helper *** ">> /root/INSTALL.LOG')
print 'END!!!'
