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


echo "Drop DB security for install..."
perl -pi -e 's|\x20ident|\x20trust|g' /var/lib/pgsql/data/pg_hba.conf

postgresql-setup initdb


echo "Enable and start postgres"
systemctl enable postgresql
systemctl start postgresql

# Configure within postgres
#echo "Entering postgress"
#sudo -i -u postgres

echo "Adding a fake user for postgres: test1/1password2"

echo "CREATEDB test1 ;
CREATE USER test1 WITH PASSWORD '1password2'  ;
ALTER ROLE test1 SET client_encoding TO 'utf8';
ALTER ROLE test1 SET default_transaction_isolation TO 'read committed';
ALTER ROLE test1 SET timezone TO 'UTC';

#give database user test1 access rights to the database test1

GRANT ALL PRIVILEGES ON DATABASE test1 TO test1;
\q " > /tmp/addpostgres.sql  # Leave postgres db

psql -h localhost -U postgres -f /tmp/addpostgres.sql

exit # Leave postgres user

echo "Allow postgres password authentication"

perl -pi -e 's|\x20ident|\x20md5|g' /var/lib/pgsql/data/pg_hba.conf
