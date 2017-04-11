import os

myNetwork=''
cloudAction='instances describe `hostname` '
cloudRegion='--zone=us-central1-c'
getMyNetwork=os.popen('gcloud compute '+cloudAction+cloudRegion).read()
getMyNetwork_l=getMyNetwork.split('\n')
for i in range(0, len(getMyNetwork_l)):
    if 'myNetwork' in getMyNetwork_l[i]:
        myNetwork=getMyNetwork_l[i+1]
myNetwork_l=myNetwork.strip().split(':')
myNetwork=myNetwork_l[1]
myNetwork=myNetwork.strip()
print myNetwork

hostnameBase='server-rsyslog1-' # Build base of rsyslog server hostname

myRsyslogServer=hostnameBase+myNetwork
print myRsyslogServer


myRsyslogConfig='/etc/rsyslog.conf'
outfile=open(myRsyslogConfig,'w')

# Precooked config file

myConfigFile='''
#  Generated rules for rsyslog.
#
#  /etc/rsyslog.conf	Configuration file for rsyslog.
#
#			For more information see
#			/usr/share/doc/rsyslog-doc/html/rsyslog_conf.html
#
#  Default logging rules can be found in /etc/rsyslog.d/50-default.conf


#################
#### MODULES ####
#################

module(load="imuxsock") # provides support for local system logging
module(load="imklog")   # provides kernel logging support
#module(load="immark")  # provides --MARK-- message capability

# provides UDP syslog reception
#module(load="imudp")
#input(type="imudp" port="514")

# provides TCP syslog reception
#module(load="imtcp")
#input(type="imtcp" port="514")

# Enable non-kernel facility klog messages
$KLogPermitNonKernelFacility on

###########################
#### GLOBAL DIRECTIVES ####
###########################

#
# Use traditional timestamp format.
# To enable high precision timestamps, comment out the following line.
#
$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat

# Filter duplicated messages
$RepeatedMsgReduction on

#
# Set the default permissions for all log files.
#
$FileOwner syslog
$FileGroup adm
$FileCreateMode 0640
$DirCreateMode 0755
$Umask 0022
$PrivDropToUser syslog
$PrivDropToGroup syslog

#
# Where to place spool and state files
#
$WorkDirectory /var/spool/rsyslog

#
# Include all config files in /etc/rsyslog.d/
#
$IncludeConfig /etc/rsyslog.d/*.conf\n'''
myConfigFile+='*.info;mail.none;authpriv.none;cron.none    @'+myRsyslogServer+':514\n'

outfile.write(myConfigFile)

print('Modifying firewall.')
pyRun=os.popen('firewall-cmd --permanent --add-port=514/tcp >> /root/INSTALL.LOG 2>&1').read()
print pyRun
pyRun=os.popen('firewall-cmd --permanent --add-port=514/udp >> /root/INSTALL.LOG 2>&1').read()
print pyRun
pyRun=os.popen('sudo firewall-cmd --reload >> /root/INSTALL.LOG 2>&1').read()

setenforce 0
print('Sleeping a moment. No race conditions please.')
pyRun=os.popen('sleep 10').read()
pyRun=os.popen('/bin/systemctl stop  rsyslog.service').read()

print('Trying rsyslog stop/starts since I have to do it manually after that last one sometimes.')
pyRun=os.popen('/bin/systemctl start  rsyslog.service').read()
