echo "Installing nano text editor..."
yum install -y nano

echo "Installing net-tools for netstat..."
yum install -y net-tools

echo "Installing git version control..."
yum install -y git

echo -n "git pull jv's automation tools [ENTER to cancel that]?"
read pullRepoConfirmation
if [ -n "$pullRepoConfirmation" ]; then
        echo "cloning jmcsagdc/Automation_NTI-310 repo to /root/Automation"
        git clone https://github.com/jmcsagdc/Automation_NTI-310.git /root/Automation
fi
