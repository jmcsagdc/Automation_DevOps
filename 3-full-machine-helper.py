import os
#myPath='/root/delete-to-reimage-on-boot'
#if os.path.isfile(myPath) is False:
myInstall=''
cloudAction='instances describe `hostname` '
cloudRegion='--zone=us-central1-c'
getMyType=os.popen('gcloud compute '+cloudAction+cloudRegion).read()
getMyType_l=getMyType.split('\n')
for i in range(0, len(getMyType_l)):
    if 'achineinstalltype' in getMyType_l[i]:
        myInstall=getMyType_l[i+1]
#print getMyType
print myInstall
if 'desktop' in myInstall:
    print 'Desktop'
    # Client machine
    doInstall=os.popen('echo "*** DESKTOP *** ">> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./utility-adjust-ssh-all-os.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./install-ldap-client-ubuntu.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python create-nfs-client-installer-ubuntu.py')
    doInstall=os.popen('echo "****** USED Python NFS client installer ****************" >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python install-rsyslog-client-50-default-all-os.py')
    doInstall=os.popen('echo "****** USED Python rsyslog client installer ************" >> /root/INSTALL.LOG 2>&1')
if 'ldap' in myInstall:
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
    doInstall=os.popen('./install-cacti-client-centos.sh >> /root/INSTALL.LOG 2>&1')
if 'nfs' in myInstall:
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
    doInstall=os.popen('./install-cacti-client-centos.sh >> /root/INSTALL.LOG 2>&1')
if 'postgres' in myInstall:
    print 'Postgres'
    # Postgres Server
    doInstall=os.popen('echo "*** POSTGRES *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./install-postgres-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python install-syslog-client-all-os.py')
    doInstall=os.popen('./install-nagios-client-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./install-cacti-client-centos.sh >> /root/INSTALL.LOG 2>&1')
if 'django' in myInstall:
    print 'Django'
    # Django and Apache server
    doInstall=os.popen('echo "*** DJANGO and APACHE *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('source /root/Automation/install-django-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('touch /root/CHANGE-FIREWALL-IN-CLOUD-FOR-PORT-8000')
    doInstall=os.popen('echo "****** CHANGE FIREWALL IN CLOUD FOR PORT 8000 ****************" >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python install-syslog-client-all-os.py')
    doInstall=os.popen('./install-nagios-client-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./install-cacti-client-centos.sh >> /root/INSTALL.LOG 2>&1')
if 'plain' in myInstall:
    print 'PLAIN'
    # Postgres Server
    doInstall=os.popen('echo "*** PLAIN *** ">> /root/INSTALL.LOG')
    #doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
    #doInstall=os.popen('python install-syslog-client-all-os.py')
    #doInstall=os.popen('./install-nagios-client-centos.sh >> /root/INSTALL.LOG 2>&1')
    #doInstall=os.popen('./install-cacti-client-centos.sh >> /root/INSTALL.LOG 2>&1')
if 'rsyslog' in myInstall:
    print 'rsyslog'
    # rsyslog Server
    doInstall=os.popen('echo "*** rsyslog *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./install-syslog-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    # DO DOT add the rsyslog client install here.
    doInstall=os.popen('./install-nagios-client-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./install-cacti-client-centos.sh >> /root/INSTALL.LOG 2>&1')
if 'build' in myInstall:
    print 'Build'
    # Build server
    doInstall=os.popen('echo "*** BUILD *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./install-build-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python install-syslog-client-all-os.py')
    doInstall=os.popen('./install-nagios-client-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./install-cacti-client-centos.sh >> /root/INSTALL.LOG 2>&1')
if 'cacti' in myInstall:
    print 'cacti'
    # cacti server
    doInstall=os.popen('echo "*** CACTI (there is a manual step involving browser) *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./install-cacti-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python install-syslog-client-all-os.py')
    doInstall=os.popen('service httpd restart')
    doInstall=os.popen('echo "*** remember to add your client configs *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./install-nagios-client-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./install-cacti-client-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python utility-add-cacti-client-hosts.py')
    doInstall=os.popen('python utility-add-cacti-graphs.py')
    doInstall=os.popen('python utility-cacti-add-hosts-to-tree.py')
if 'nagios' in myInstall:
    print 'nagios'
    # nagios server
    doInstall=os.popen('echo "*** NAGIOS *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./install-nagios-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python install-syslog-client-all-os.py')
    doInstall=os.popen('echo "*** remember to add your client configs *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./install-nagios-client-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./install-cacti-client-centos.sh >> /root/INSTALL.LOG 2>&1')
if 'yum' in myInstall:
    print 'yum'
    # nagios server
    doInstall=os.popen('echo "*** NAGIOS *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./install-yum-repository-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python install-syslog-client-all-os.py')
    doInstall=os.popen('./install-nagios-client-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./install-cacti-client-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('python utility-add-nagios-client-configs.py')
print 'END!!!'
#    pyRun=os.popen('touch /root/delete-to-reimage-on-boot')
#else:
#    doInstall=os.popen('echo "*** reboot `date` *** ">> /root/delete-to-reimage-on-boot')
#    pass
