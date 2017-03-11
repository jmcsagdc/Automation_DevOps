import os

hostnameBase='server-rsyslog-' # Build base of rsyslog server hostname

myHostname=os.popen('hostname').read()
mySubnet=''
count=0
mySubnet_l=myHostname.strip().split('-')

for i in range(1, len(mySubnet_l)):
    if count==0:
        mySubnet+=mySubnet_l[i]
    else:
        mySubnet+='-'+mySubnet_l[i]
    count+=1
myRsyslogServer=hostnameBase+mySubnet
print myRsyslogServer

outfile=open('rsyslogclients_mount.sh','w')
outfile.write('echo "*.info;mail.none;authpriv.none;cron.none    @'+myRsyslogServer+'\n" >> /etc/rsyslog.conf')
outfile.write('service rsyslog restart\n')
outfile.close()
# Big sleep avoids race condition where client tries to mount a server not up yet.

pyRun=os.popen('sleep 60').read()
pyRun=os.popen('echo "************* Changing perms /root/Automation/rsyslogclients_mount.sh ************" >> /root/INSTALL.LOG 2>&1').read()
pyRun=os.popen('chmod +x /root/Automation/rsyslogclients_mount.sh').read()
pyRun=os.popen('echo "************* Running /root/Automation/rsyslogclients_mount.sh ************" >> /root/INSTALL.LOG 2>&1').read()
pyRun=os.popen('/root/Automation/rsyslogclients_mount.sh').read()
