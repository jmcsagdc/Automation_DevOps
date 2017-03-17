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

hostnameBase='server-rsyslog-' # Build base of rsyslog server hostname
'''
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
'''
myRsyslogServer=hostnameBase+myNetwork
print myRsyslogServer


myRsyslogConfig='/etc/rsyslog.d/50-default.conf'
outfile=open(myRsyslogConfig,'w')

# Precooked config file

myConfigFile='''
#  Generated rules for rsyslog.
#
#  For more information see rsyslog.conf(5) and /etc/rsyslog.conf

#
# First some standard log files.  Log by facility.
#\n'''
myConfigFile+='auth,authpriv.*         @'+myRsyslogServer+'\n'
myConfigFile+='*.*;auth,authpriv.none      @'+myRsyslogServer+'\n'
myConfigFile+='''#cron.*             /var/log/cron.log
#daemon.*           -/var/log/daemon.log\n'''
myConfigFile+='kern.*              @'+myRsyslogServer+'\n'
myConfigFile+='#lpr.*              -/var/log/lpr.log\n'
myConfigFile+='mail.*              @'+myRsyslogServer+'\n'
myConfigFile+='''#user.*             -/var/log/user.log

#
# Logging for the mail system.  Split it up so that
# it is easy to write scripts to parse these files.
#
#mail.info          -/var/log/mail.info
#mail.warn          -/var/log/mail.warn\n'''
myConfigFile+='mail.err            @'+myRsyslogServer+'\n'
myConfigFile+='''\n
#
# Logging for INN news system.
#\n'''
myConfigFile+='news.crit           @'+myRsyslogServer+'\n'
myConfigFile+='news.err            @'+myRsyslogServer+'\n'
myConfigFile+='news.notice         @'+myRsyslogServer+'\n'
myConfigFile+='''\n
#
# Some "catch-all" log files.
#
#*.=debug;\
#   auth,authpriv.none;\\
#   news.none;mail.none -/var/log/debug
#*.=info;*.=notice;*.=warn;\\
#   auth,authpriv.none;\\
#   cron,daemon.none;\\
#   mail,news.none      -/var/log/messages

#
# Emergencies are sent to everybody logged in.
#
*.emerg                                :omusrmsg:*

#
# I like to have messages displayed on the console, but only on a virtual
# console I usually leave idle.
#
#daemon,mail.*;\\
#   news.=crit;news.=err;news.=notice;\\
#   *.=debug;*.=info;\\
#   *.=notice;*.=warn   /dev/tty8

# The named pipe /dev/xconsole is for the `xconsole' utility.  To use it,
# you must invoke `xconsole' with the `-file' option:
# 
#    $ xconsole -file /dev/xconsole [...]
#
# NOTE: adjust the list below, or you'll go crazy if you have a reasonably
#      busy site..
#
#daemon.*;mail.*;\\
#    news.err;\\
#    *.=debug;*.=info;\\
#    *.=notice;*.=warn   |/dev/xconsole'''

outfile.write(myConfigFile)

print('Modifying firewall.')
pyRun=os.popen('firewall-cmd --permanent --add-port=514/tcp >> /root/INSTALL.LOG 2>&1').read()
print pyRun
pyRun=os.popen('firewall-cmd --permanent --add-port=514/udp >> /root/INSTALL.LOG 2>&1').read()
print pyRun
pyRun=os.popen('sudo firewall-cmd --reload >> /root/INSTALL.LOG 2>&1').read()

print('Sleeping a minute. No race conditions please.')
pyRun=os.popen('sleep 30').read()
pyRun=os.popen('/bin/systemctl stop  rsyslog.service').read()

print('Trying rsyslog stop/starts since I have to do it manually after that last one sometimes.')
pyRun=os.popen('/bin/systemctl start  rsyslog.service').read()
