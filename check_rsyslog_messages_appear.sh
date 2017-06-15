# Add to nrpe.cfg:
# command[check_rsyslog_messages_appear]=/usr/lib64/nagios/plugins/check_rsyslog_messages_appear$
#
#
# Add to nagios's server command configs for each <MONITORED_SERVER_NAME>.cfg file:
# define service{
#        use                             generic-service         ; Service template
#        host_name                       <MONITORED_SERVER_NAME>
#        service_description             Check Logging
#        check_command                   <UNIQUE_COMMAND_NAME>
#}
#
#define command {
#       command_name     check_rsyslog_messages_appear_server-rsyslog1-final5
#       command_line     /usr/local/nagios/libexec/check_nrpe -H <MONITORED_SERVER_NAME> -c <UNIQUE_COMMAND_NAME>
#}
#
# PLUGIN:
# Step one: The thing to check for
# newlogline="check `date`"
# logger $newlogline
#
# Step two: Likely need a little sleep here
#
# Step three: Check for that thing
# grep $newlogline /var/log/messages
#
#

#check_rsyslog_messages_appear() {
    newlogline="CHECKING `date`"
    logger $newlogline
    #echo $newlogline
    sleep 5

    # Below we are returning error codes:

    fullLogLine=$(grep "$newlogline" /var/log/messages)
    cleanLogLine=$(echo $fullLogLine | awk -F ": " '{ print $2 }')
    
    if [[ $newlogline==$cleanLogLine ]]; then	   # this means line appeared
      echo "GOOD"; exit 0;
    else
      if [[ $cleanLogLine=='' ]]; then             # if the result has nothing (BAD - no hits)
        echo "ALERT"; exit 2;
      else echo "WARN: Uncaptured Plugin Result"; exit 1;  # Shouldn't really happen - exception
      fi
    fi
#}
