import os
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
if '1' in myInstall:
    print 'Desktop'
    # Client machine
    doInstall=os.popen('echo "*** DESKTOP *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./utility-adjust-ssh-all-os.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./install-ldap-client-ubuntu.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('touch /root/use-NFS-client-script-creator-on-server')
    doInstall=os.popen('echo "****** USE NFS CREATOR SCRIPT ****************"')
    # Figure out NFS client builder from CentOS server.
if '2' in myInstall:
    print 'LDAP'
    # LDAP Server
    doInstall=os.popen('echo "*** LDAP *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./install-ldap-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    #doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
if '3' in myInstall:
    print 'NFS'
    # NFS Server
    doInstall=os.popen('echo "*** NFS *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./install-nfs-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    # ./utility-nfs-server-add-client-centos.sh # Change to subnet to do this
    doInstall=os.popen('touch /root/use-utility-nfs-server-add-client-centos.sh-now')
    doInstall=os.popen('./create-nfs-client-installer-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
if '4' in myInstall:
    print 'Postgres'
    # Postgres Server
    doInstall=os.popen('echo "*** POSTGRES *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./install-postgres-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
if '5' in myInstall:
    print 'Django'
    # Django and Apache server
    doInstall=os.popen('echo "*** DJANGO and APACHE *** ">> /root/INSTALL.LOG')
    doInstall=os.popen('./install-django-server-centos.sh >> /root/INSTALL.LOG 2>&1')
    doInstall=os.popen('./utility-adjust-harden-centos.sh >> /root/INSTALL.LOG 2>&1')
print 'END!!!'
