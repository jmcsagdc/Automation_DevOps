import os

hostnameBase='server-nagios1-' # Build base of nfs server hostname

myHostname=os.popen('hostname').read()
mySubnet=''
count=0
mySubnet_l=myHostname.strip().split('-')

for i in range(2, len(mySubnet_l)):
    if count==0:
        mySubnet+=mySubnet_l[i]
    else:
        mySubnet+='-'+mySubnet_l[i]
    count+=1
myNagiosServer=hostnameBase+mySubnet
print myNagiosServer
