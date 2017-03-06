myKernel=$(uname -r | grep 'generic')
sleep 5
echo 'myKernel is ' $myKernel

if uname -r | grep 'generic' 1>/dev/null
then
  echo "Wrong OS" # If Ubuntu is NOT target OS
  exit 1
else
  echo "CentOS is correct for server"
  #echo "Wrong OS" # If redhat is NOT target
  #exit 1
fi

# Get global IP
echo "Getting global IP"
testglobalip=`curl -A '"Mozilla/4.0"' 91.198.22.70`
echo "TESTGLOBALIP results: $testglobalip"

myglobalip=`echo $testglobalip | awk '{print $NF}' | awk -F'<' '{print $1}'`

echo "myglobalip = $myglobalip"

myhostname=`hostname`

echo "myhostname= $myhostname"
sleep 5
# First the local permissions
echo "Back up sudoers"
cp /etc/sudoers /etc/sudoers.orig
echo "Only adm members get sudo..."
perl -pi -e 's|## Allows people in group wheel to run all commands|## Allows people in group adm to run all commands|g' /etc/sudoers
perl -pi -e 's|\x25wheel|\x25adm|g' /etc/sudoers

# Disallow SSH for regions outside US

# Disallow passworded logins for SSH on servers

# Firewall

# Ports for NFS (if applicable)

# 
