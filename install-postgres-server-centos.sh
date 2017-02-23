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

echo "Installing postgres server packages"
yum install -y postgresql-server postgresql-contrib

echo "Allow postgres password authentication"
postgresql-setup initdb

perl -pi -e "s|host    all             all             127.0.0.1/32            ident
host    all             all             ::1/128                 ident|host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5|g" /var/lib/pgsql/data/pg_hba.conf

echo "Enable and start postgres"
systemctl enable postgresql
systemctl start postgresql

# Configure within postgres
#echo "Entering postgress"
#sudo -i -u postgres

echo "Adding a fake user for postgres: dave/1password2"
echo "1password2" > /tmp/xxx.pass

psql -U postgres postgres <<OMG
 CREATE USER dave password '`cat /tmp/xxx.pass`' ;
OMG

rm -f /tmp/xxx.pass

