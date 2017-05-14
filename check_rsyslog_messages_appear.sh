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
    newlogline="check `date`"
    logger $newlogline

    sleep 5

    # Below we are returning error codes:
    dave=$(grep $newlogline /var/log/messages)
    if [[ $dave == $newlogline ]]; then  # this means line appeared                
      echo "GOOD: Match"; exit 0;
    else
      if [[ $dave == '' ]]; then         # if the result has nothing (BAD - no hits)
        echo "BAD: No Match"; exit 2;
      else echo "WARN: Partial"; exit 1;       # if result is not empty but isn't a hit? #TODO fix this. This is stupid
      fi
    fi
}

#TODO: Fix. Detecting matches as partials because the log format contains more info

#TEST:

    newlogline="check `date`"
    logger $newlogline
    echo $newlogline
    sleep 5

    # Below we are returning error codes:
    dave=$(grep "$newlogline" /var/log/messages)
    if [[ $dave == $newlogline ]]; then  # this means line appeared
      echo "GOOD: Match"; exit 0;
    else
      if [[ $dave == '' ]]; then         # if the result has nothing (BAD - no hits)
        echo "BAD: No Match"; exit 2;
      else echo "WARN: Partial: $dave"; exit 1;       # if result is not empty but isn't a hit? #TODO fix this. This is stupid
      fi
    fi
