#!/bin/sh

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

print_revision() {
	echo "$1 v$2 (jmcsagdc-plugins 0.1)"
	printf '%b' "The jmcsagdc plugins come with ABSOLUTELY NO WARRANTY. You may redistribute\ncopies of the plugins under the terms of the GNU General Public License.\n"
}

support() {
	printf '%b' "Offered without support of any kind.\n"
}

#
# Check contents of /root/Automation against fingerprint
# Pass is a match - diff returns nothing
# Warn *is a partial* - diff returns something
#
# Alert *is missing* - 'cannot access Automation: No such file or directory'
# ls Automation > test.txt 2>&1
# diff test.txt fingerprint.txt
#
# TODO: Instead of echoing, set a return code for above states
# TODO: Create a fingerprint file to include with the rpm or maybe just make it easier somehow
#

check_automation_folder() {
	
	# Below we are returning error codes:
	
    ls /root/Automation > test.txt 2>&1        # make a file to compare to thumbprint
    dave=$(diff test.txt fingerprint.txt)      # compare the files and get result
    if [[ $dave == *"cannot access"* ]]; then  # if result is a 'not found style' message
      echo "ALERT: Missing"; exit 2;
    else
      if [[ $dave == '' ]]; then               # if the result has nothing (good - no hits)
        echo "GOOD: Match"; exit 0;
      else echo "WARN: Partial"; exit 1;       # if result is not empty (meaning hits)
      fi
    fi
}
