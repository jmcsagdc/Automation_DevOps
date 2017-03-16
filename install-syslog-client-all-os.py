import os

#TODO Add the newer naming logic here and remove the below...



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
myConfigFile+='auth,authpriv.*         @server-rsyslog-bunch\n'
myConfigFile+='*.*;auth,authpriv.none      @server-rsyslog-bunch\n'
myConfigFile+='''#cron.*             /var/log/cron.log
#daemon.*           -/var/log/daemon.log\n'''
myConfigFile+='kern.*              @server-rsyslog.bunch\n'
myConfigFile+='#lpr.*              -/var/log/lpr.log\n'
myConfigFile+='mail.*              @server-rsyslog-bunch\n'
myConfigFile+='''#user.*             -/var/log/user.log

#
# Logging for the mail system.  Split it up so that
# it is easy to write scripts to parse these files.
#
#mail.info          -/var/log/mail.info
#mail.warn          -/var/log/mail.warn\n'''
myConfigFile+='mail.err            @server-rsyslog-bunch\n'
myConfigFile+='''\n
#
# Logging for INN news system.
#\n'''
myConfigFile+='news.crit           @server-rsyslog-bunch\n'
myConfigFile+='news.err            @server-rsyslog-bunch\n'
myConfigFile+='news.notice         @server-rsyslog-bunch\n'
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
daemon.*;mail.*;\\
    news.err;\\
    *.=debug;*.=info;\\
    *.=notice;*.=warn   |/dev/xconsole'''

outfile.write(myConfigFile)
pyRun=os.popen('sleep 60').read()
pyRun=os.popen('service rsyslog restart').read()
