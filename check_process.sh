# Add to <MONITORED_SERVER_NAME> config: nrpe.cfg:
# command[check_process]=/usr/lib64/nagios/plugins/check_process.sh <list of processes separated by spaces>
# like:
# command[check_process]=/usr/lib64/nagios/plugins/check_process.sh sshd httpd
#
# Add to nagios's server command configs for each <MONITORED_SERVER_NAME>.cfg file:
# define service{
#        use                             generic-service         ; Service template
#        host_name                       <MONITORED_SERVER_NAME>
#        service_description             Check My Processes
#        check_command                   <UNIQUE_COMMAND_NAME>
# }
#
# define command {
#       command_name     check_process_nfs1
#       command_line     /usr/local/nagios/libexec/check_nrpe -H <MONITORED_SERVER_NAME> -c <UNIQUE_COMMAND_NAME>
#
# PLUGIN:
# Step one: Check for missing processes
# iterate through the args process list and compare each to content of a filtered ps
# missing = ALERT
#
# Step two: Check for zombies
# just grep for the literal 'Z' in contents of a filtered ps
# 
# Step three: Check myState and act appropriately
# just check for each state and exit. if neither alert nor warn, assume good.

#check_process() {
myState==0
aProcessNameList=`ps -ax | awk '{ print $5 }' | sort | uniq`
aProcessStateList=`ps -ax | awk '{ print $3 }'`

#for i in $*; do echo "$i"; done
                                                           # Step one: Check for missing processes
for i in $*; do                                            # Iterate list of process names from args
  if echo $aProcessNameList | grep -q $(echo "$i"); then   # is arg 'i' found in aProcessNameList?
    myState=0                                              # DEBUG we are OK
  else
    myState=2                                              # I'm missing an expected process. Set myState to ALERT
  fi
done

# Step two: Check for zombies
if echo $aProcessStateList | grep -q "Z"; then  # is the Z for zombie found in the contents of aProcessStateList?
  myState=1  # I found a Zombie. Set myState to WARN
fi

# Step three: Check myState and act appropriately
if [[ $myState -eq 2 ]]; then
  echo "CRITICAL"
  exit 2
fi

if [[ $myState -eq 1 ]]; then
  echo "WARN"
  exit 1
fi

echo "GOOD"; exit 0
#}
