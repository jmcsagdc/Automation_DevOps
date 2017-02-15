echo "Checking for Ubuntu"

myKernel=$(uname -r | grep 'generic')

echo 'myKernel is ' $myKernel

if uname -r | grep 'generic' 1>/dev/null
then
  echo "Ubuntu is correct for server"
  #echo "Wrong OS" # If Ubuntu is NOT target OS
  #exit 1
else
  echo "Wrong OS" # If redhat is NOT target
  exit 1
fi

echo "Installing tree utility"
apt install -y tree

echo "Installing htop utility"
apt install -y htop



echo -n "git pull jv's automation tools [ENTER to cancel that]?"
read pullRepoConfirmation
if [ -n "$pullRepoConfirmation" ]; then
        echo "cloning jmcsagdc/Automation_NTI-310 repo to /root/Automation"
        git clone https://github.com/jmcsagdc/Automation_NTI-310.git /root/Automation
fi
