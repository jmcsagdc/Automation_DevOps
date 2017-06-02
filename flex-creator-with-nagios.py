# Build a local creator to use. Likely just redo this later.
# Right now, just throwing stuff at the wall to see what sticks.

nicNagiosScript='nic-nagios-script.sh'
nicNagiosFile=open(nicNagiosScript,'w')

scriptContents='''
#!/bin/bash
host="$1" # get these from python's call to this script
ip="$2"
# Modified by jmcsagdc just to remove the
# error-checking and usage since this will go to 
# a wrapper for execution. The wrapper is likely
# just a call from the flexible-creator.py
echo "
# Host Definition
define host {
    use         linux-server        ; Inherit default values from a template
    host_name   $host               ; The name we're giving to this host
    alias       web server          ; A longer name associated with the host
    address     $ip                 ; IP address of the host
}
# Service Definition
define service{
        use                             generic-service         ; Name of service template to
        host_name                       $host
        service_description             load
        check_command                   check_nrpe!check_load
}
define service{
        use                             generic-service         ; Name of service template to
        host_name                       $host
        service_description             users
        check_command                   check_nrpe!check_users
}
define service{
        use                             generic-service         ; Name of service template to
        host_name                       $host
        service_description             disk
        check_command                   check_nrpe!check_disk
}
define service{
        use                             generic-service         ; Name of service template to
        host_name                       $host
        service_description             totalprocs
        check_command                   check_nrpe!check_total_procs
}
define service{
        use                             generic-service         ; Name of service template to
        host_name                       $host
        service_description             memory
        check_command                   check_nrpe!check_mem
}
">> /tmp/"$host".cfg # Drop this into temp location for scp into cloud instance
'''

nicNagiosFile.write(scriptContents)
nicNagiosFile.close()

nagiosScpList=[]
# GET the nagiosServerList This can go up top.
for aServer in servers:
    if 'server-nagios' in aServer:
    nagiosServerList.append(aServer)


################################################################################
# VM CREATION HERE. Put this immediately after execution of instance create line
# For each VM creation, do this to get that IP:
myLines=pyRun.split('\n') # results on three lines
myLine=myLines[2].strip() # we just want the last one
items=myLine.split()      # multiple elements included
newIP=items[3]            # we just want that internal IP

# build the string to create this instance's cfg for the nagios server
pyNagiosCreateString='nic-nagios-script.sh '+createMachineName+' '+newIP
pyRun=os.popen(pyNagiosCreateString).read()

# add this server to the queue to scp soon
for destinationServer in nagiosServerList:
    scpListLine='gcloud compute scp /tmp/'+createMachineName'.cfg '+destinationServer':/tmp/'
    nagiosScpList.append(scpListLine)

# At this point all instances are being created, one at a time. SCP after.
################################################################################

# SCP cfg files to all Nagios servers. This goes down at the end.
# Likely, we'd want more than one monitoring station and this is just easier

for each in nagiosScpList:
    pyRun=os.popen(scpListLine).read() # execute each scp in list.
    print pyRun # return result to console and move on to next
                # scp action for this Nagios server. This way, 
                # each server receives full scp list of files
