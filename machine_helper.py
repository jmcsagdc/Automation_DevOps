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
    print 'I is Desktop'
if '2' in myInstall:
    print 'I is LDAP'
if '3' in myInstall:
    print 'I is NFS'
if '4' in myInstall:
    print 'I is Postgres'
if '5' in myInstall:
    print 'I is Django'
print 'END!!!'
