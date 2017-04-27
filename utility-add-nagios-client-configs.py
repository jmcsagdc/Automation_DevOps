
from helpers import *
import os

pyRun=os.popen('mkdir tmpFiles').read()
print "Created tmpFiles dir. If script fails, check here for configs."

myServers, names, local_ips=GetCloudHostsData()

myNetwork=GetMyNetworkName()
print myNetwork

myFile=''

for i in range(0, len(names)):

    myFile='''define host {
        use                             linux-server
        host_name                       '''+names[i]+'\n'
    myFile+='        alias                           My '+names[i]+' server\n'
    myFile+='        address                         '+local_ips[i]+'\n'
    myFile+='''        max_check_attempts              5
        check_period                    24x7
        notification_interval           30
        notification_period             24x7
}

define service {
        use                             generic-service
        host_name                       '''+names[i]+'\n'
    myFile+= '''        service_description             PING
        check_command                   check_ping!100.0,20%!500.0,60%
}
define service {
        use                             generic-service
        host_name                       '''+names[i]+'\n'
    myFile+= '''        Root Partition
        check_command                  check_nrpe!check_disk!20%!10%!/
	contact_groups                 admins
        contacts                       alert_priority
}'''

    outfileName='tmpFiles/'+names[i]+'.cfg'
    outfile=open(outfileName,'w')
    outfile.write(myFile)
    outfile.close()

myPath='tmpFiles/*'+myNetwork+'*'
myCommand='cp '+myPath+' /usr/local/nagios/etc/servers/.'
pyRun=os.popen(myCommand).read()
print pyRun

pyRun=os.popen('echo "reloading nagios service: systemctl reload nagios.service"').read()
pyRun=os.popen('systemctl reload nagios.service').read()

print pyRun

print "END!"
