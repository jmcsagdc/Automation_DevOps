myKernel=$(uname -r | grep 'generic')

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

echo "Installing nano text editor..."
yum install -y nano

echo "Installing net-tools for netstat..."
yum install -y net-tools

echo "Installing git version control..."
yum install -y git

echo "Installing locate tool..."
yum install -y mlocate

echo -n "git pull jv's automation tools [ENTER to cancel that]?"
read pullRepoConfirmation
if [ -n "$pullRepoConfirmation" ]; then
        echo "cloning jmcsagdc/Automation_NTI-310 repo to /root/Automation"
        git clone https://github.com/jmcsagdc/Automation_NTI-310.git /root/Automation
fi
