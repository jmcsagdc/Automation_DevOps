

#!/bin/bash
# CentOS only

echo "BEGIN *************************************** django install script"
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

useradd django-user

server_ip_address=$(gcloud compute instances list | grep `hostname` | awk '{ print $5 }')

echo "Adding epel-release for yum..."
yum install epel-release
yum -y update

echo "Installing pip for python..."
yum -y install python-pip

echo "Here's your pip..."
pip -V

#### VIRTUAL ENVIRONMENT ####

pip install virtualenv

cd /opt

mkdir /opt/django
chown -R django-user django

sleep 5

cd /opt/django
virtualenv django-env

echo "activating virtualenv"

source /opt/django/django-env/bin/activate

echo "to switch out of virtualenv, type deactivate"

echo "now using: `which python`"

chown -R django-user /opt/django

echo "installing django"


echo "Installing django...and postgres connector"
pip install django psycopg2

echo "Here's your django install..."
django-admin --version

####
# VIRUAL ENV VERSION
####

echo "Sleeping 60s from `date`"
sleep 60
echo "Done sleeping. Try to add project."

projectname="mycuteproject"
django-admin startproject mycuteproject
#python /usr/bin/django-admin.py startproject mycuteproject
cd $projectname

# Add the allowed host line
perl -pi -e "s|ALLOWED_HOSTS = \[\]|ALLOWED_HOSTS = \['*'\]|g" /opt/django/mycuteproject/mycuteproject/settings.py

# Search and replace the settings.py
echo "Search and replace the settings.py"
djangoX=$HOSTNAME
myNetwork=$(echo $djangoX | cut -d'-' -f3)
djangoY=$(echo $djangoX | awk --field-separator '-' '{ print $2 }' | sed "s/[^[:digit:]]//g")
mySqlServer="server-sql$djangoY-$myNetwork"
perl -pi -e 's|django.db.backends.sqlite3|django.db.backends.postgresql_psycopg2|g' /opt/django/mycuteproject/mycuteproject/settings.py
perl -pi -e "s|os\x2Epath\x2Ejoin\x28BASE_DIR\x2C \x27db\x2Esqlite3\x27\x29|\x27test1\x27\x2C\n        \x27USER\x27\x3A \x27test1\x27\x2C\n        \x27PASSWORD\x27\x3A \x271password2\x27\x2C\n        \x27HOST\x27\x3A \x27$mySqlServer\x27\x2C\n        \x27PORT\x27\x3A \x275432\x27|g" /opt/django/mycuteproject/mycuteproject/settings.py


python manage.py makemigrations
python manage.py migrate
# If the above does not work, try this: python manage.py syncdb

# This is interactive. Need a scriptable solution
#python manage.py createsuperuser
echo "from django.contrib.auth.models import User; User.objects.create_superuser('jmcsagdc', 'user@test.com', 'blahblahblah')" | python /opt/django/mycuteproject/manage.py shell


echo "In a browser try to admin this setup: http://$server_ip_address:8000/admin"

# Development style. Insecure.
python /opt/django/mycuteproject/manage.py runserver 0.0.0.0:8000 &

# Verify it works
echo "Verify django site:"
curl $server_ip_address:8000 >> /root/INSTALL.LOG
