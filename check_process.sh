# Add to nrpe.cfg:
# command[check_process]=/usr/lib64/nagios/plugins/check_process.sh <list of processes separated by spaces>
#
# Step one: Check for missing processes
# iterate through the args process list and compare each to content of a filtered ps
# missing = ALERT
#
# Step two: Check for zombies
# just grep for the literal 'Z' in contents of a filtered ps
# 
# Step three: Check myState and act appropriately
# just check for each state and exit. if neither alert nor warn, assume good.

check_process() {
myState==0
aProcessNameList=`ps -ax | awk '{ print $5 }' | sort | uniq`
aProcessStateList=`ps -ax | awk '{ print $3 }'`
#echo $aProcessStateList
#echo $aProcessNameList

# Step one: Check for missing processes
for i in $*; do   # This iterates through the list of process names from command line args
  if echo $aProcessNameList | grep -q $i; then   # is this arg 'i' found in the contents of aProcessNameList?
    echo "`date` [healthcheck] - Found $i >> /var/log/messages"
  else
    echo "`date` [healthcheck] - $i MISSING" >> /var/log/messages; myState=2    # I'm missing an expected process. Set myState to ALERT
  fi
done

# Step two: Check for zombies
if echo $aProcessStateList | grep -q "Z"; then  # is the Z for zombie found in the contents of aProcessStateList?
  echo "`date` [healthcheck] - Zombie Found" >> /var/log/messages; myState=1  # I found a Zombie. Set myState to WARN
fi

# Step three: Check myState and act appropriately
if [[ $myState==2 ]]; then
  exit 2
fi

if [[ $myState==1 ]]; then
  exit 1
fi

echo "`date` [healthcheck] - I'm GOOD" >> /var/log/messages; exit 0
}
