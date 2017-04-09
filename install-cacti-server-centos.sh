echo "Install cacti dependencies"

yum install -y httpd httpd-devel
yum install -y mysql mysql-server
yum install -y mariadb-server
yum install -y php-mysql php-pear php-common php-gd php-devel php php-mbstring php-cli
yum install -y php-snmp
yum install -y net-snmp-utils net-snmp-libs
yum install -y rrdtool

echo "Start services for httpd, snmpd, mariadb"

systemctl start httpd.service
systemctl start snmpd.service
systemctl start mariadb.service

echo "Enable these to start on boot"

systemctl enable httpd.service
systemctl enable mariadb.service
systemctl enable snmpd.service

echo "Install cacti"

yum install -y cacti

echo "Add mysql root user password ( see /root/mysql_root_pass )"
mysqladmin -u root password Passw0rd
echo "Passw0rd" >> /root/mysql_root_pass
chmod 600 /root/mysql_root_pass

echo "Create DB"
mysql -u root -pPassw0rd << EOF
CREATE DATABASE cacti ;
GRANT ALL ON cacti.* TO cacti@localhost IDENTIFIED BY 'tecmint';
FLUSH privileges;
quit;
EOF

echo "run cacti db script"
mysql -u root -pPassw0rd cacti < `rpm -ql cacti | grep cacti.sql`

echo "perform config file user substitutions"
perl -pi -e "s|database_username = 'cactiuser'|database_username = 'root'|g" /etc/cacti/db.php
perl -pi -e "s|database_password = 'cactiuser'|database_password = 'Passw0rd'|g" /etc/cacti/db.php
#TODO maybe change this to a different user

echo "Back up /etc/httpd/conf.d/cacti.conf as orig"
cp /etc/httpd/conf.d/cacti.conf /etc/httpd/conf.d/cacti.conf.orig

echo "Modify webserver permissions"
perl -pi -e "s|Require host localhost|Require all granted|g" /etc/httpd/conf.d/cacti.conf
perl -pi -e "s|Allow from localhost|Allow from all|g" /etc/httpd/conf.d/cacti.conf

echo "At this point you can verify that something is visible in <IP>/cacti/install"

echo "Back up /etc/cron.d/cacti as orig"
cp /etc/cron.d/cacti /etc/cron.d/cacti.orig

echo "Overwrite /etc/cron.d/cacti with desired polling time"
echo '*/5 * * * *    cacti   /usr/bin/php /usr/share/cacti/poller.php > /dev/null 2>&1' > /etc/cron.d/cacti

echo "MANUAL INSTALLING VIA WEBPAGES"
