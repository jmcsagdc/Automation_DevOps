from helpers import *

myServers, names, local_ips=GetCloudHostsData()
#print myServers

#myRows=myServers.split('\n')
#print myRows

#name=['bobross','freddkrueger']
#ip=['1.2.3.4','5.6.7.8']


for i in range(0, len(names)):

    print '''define host {
        use                             linux-server
        host_name                       '''+names[i]+'\n'
    print '''        alias                           My first postgres server
        address                         '''+local_ips[i]+'\n'
    print '''        max_check_attempts              5
        check_period                    24x7
        notification_interval           30
        notification_period             24x7
}

define service {
        use                             generic-service
        host_name                       '''+names[i]+'\n'
    print '''        service_description             PING
        check_command                   check_ping!100.0,20%!500.0,60%
}'''

print 'END'
print names
print local_ips
