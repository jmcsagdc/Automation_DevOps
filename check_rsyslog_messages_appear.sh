# Add to nrpe.cfg:
# command[check_rsyslog_messages_appear]=/usr/lib64/nagios/plugins/check_rsyslog_messages_appear.sh
#
# Here's the thing to check for
# newlogline="check `date`"    
# logger $newlogline  
#
# Likely need a	little sleep here
#
# Here's the check for that thing
# grep $newlogline /var/log/messages                          
#                                                                    
#

check_rsyslog_messages_appear() {
    newlogline="CHECKING `date`"
    logger $newlogline
    #echo $newlogline
    sleep 5

    # Below we are returning error codes:

    fullLogLine=$(grep "$newlogline" /var/log/messages)
    cleanLogLine=$(echo $fullLogLine | awk -F ": " '{ print $2 }')
    #echo $cleanLogLine

    if [[ $newlogline == $cleanLogLine ]]; then      # this means line appeared
      echo "GOOD: Match [ $newlogline ] IS IN [ $fullLogLine ]"; exit 0;
    else
      if [[ $cleanLogLine == '' ]]; then             # if the result has nothing (BAD - no hits)
        echo "BAD: No Match"; exit 2;
      else echo "WARN: Uncaptured Plugin Result"; exit 1;  # Shouldn't really happen - exception 
      fi
    fi
}
