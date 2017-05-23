echo "Installing local YUM REPOSITORY"


yum install -y vsftpd

perl -pi -e 's|listen=NO|listen=yes|g' /etc/vsftpd/vsftpd.conf
perl -pi -e 's|listen_ipv6=YES|#listen_ipv6=YES|g' /etc/vsftpd/vsftpd.conf

systemctl enable vsftpd
systemctl start vsftpd

mkdir -p /var/ftp/pub/localrepo/CentOS/7/0

mv ~/*.rpm /var/ftp/pub/localrepo/.

#nano /etc/yum.repos.d/myrepo.repo
echo "[myrepo]
name=Network Repository
baseurl=ftp://<SERVERNAME>/pub/localrepo/CentOS/7/0/x86_64
gpcheck=0
enabled=1" > /etc/yum.repos.d/myrepo.repo

# LOCAL
echo "[mylocalrepo]
name=My Local Repository
baseurl=file:///var/ftp/pub/localrepo/CentOS/7/0/x86_64
gpgcheck=0
enabled=1" > /etc/yum.repos.d/mylocalrepo.repo

createrepo -v  /var/ftp/pub/localrepo/CentOS/7/0/x86_64

yum update

yum repolist

yum --disablerepo "*" --enablerepo "myrepo" list available

setenforce 0

echo "Finished installing YUM PREOSITORY"
