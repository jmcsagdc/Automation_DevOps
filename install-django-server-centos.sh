# CentOS only
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

# Run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run by the root user" 1>&2
    exit 1
fi

echo "Adding epel-release for yum..."
yum install epel-release
yum -y update

echo "Installing pip for python..."
yum -y install python-pip

echo "Here's your pip..."
pip -V

echo "Installing django..."
pip install django

echo "Here's your django global install..."
django-admin --version

#########################################################
# FOLLOWING IS INTERACTIVE. HARDCODE FOR SIMPLE INSTALL #
#########################################################
# django project creation
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "What projectname for django would you like?"
read projectname

django-admin startproject $projectname
cd $projectname

# django-admin startproject simpleprojectname
# cd simpleprojectname

python manage.py migrate
# If the above does not work, try this: python manage.py syncdb

# This is interactive. Need a scriptable solution
python manage.py createsuperuser

# Development style. Insecure.
python manage.py runserver 0.0.0.0:8000

# Verify it works
echo "Verify django site:"
curl server_ip_address:8000

echo "In a browser try to admin this setup: server_ip_address:8000/admin"