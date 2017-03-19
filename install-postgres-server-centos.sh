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

postgresql-setup initdb

# SE Linux allow httpd
setsebool -P httpd_can_network_connect_db on

echo "Drop DB security for install..."
perl -pi -e 's|\x20ident|\x20trust|g' /var/lib/pgsql/data/pg_hba.conf

perl -pi -e "s|#listen_addresses = 'localhost'|listen_addresses = '*'|g" /var/lib/pgsql/data/postgresql.conf
perl -pi -e "s|\x23 IPv4 local connections:\n|\x23 IPv4 local connections:\nhost    all             all             0.0.0.0/0      md5\n|g" /var/lib/pgsql/data/pg_hba.conf

echo "Enable and start postgres"
systemctl enable postgresql
systemctl start postgresql

echo "Adding a fake user for postgres: test1/1password2"

echo "CREATE DATABASE test1 ;
CREATE USER test1 WITH PASSWORD '1password2';
ALTER ROLE test1 SET client_encoding TO 'utf8';
ALTER ROLE test1 SET default_transaction_isolation TO 'read committed';
ALTER ROLE test1 SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE test1 TO test1;
\q " > /tmp/addpostgres.sql  # Leave postgres db

psql -h localhost -U postgres -f /tmp/addpostgres.sql

exit # Leave postgres user

echo "Clean up..."
rm -f /tmp/addpostgres.sql

echo "Allow postgres password authentication"

perl -pi -e 's|\x20trust|\x20md5|g' /var/lib/pgsql/data/pg_hba.conf
systemctl restart postgresql
echo "Resecured DB login"
echo "****DONE****"
