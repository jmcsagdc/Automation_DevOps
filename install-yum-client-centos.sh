myYumServer=$(gcloud compute instances list | grep "yum\|repo" | awk "{ print $1 }") 

echo "Installing CLIENT YUM REPOSITORY"

#nano /etc/yum.repos.d/myrepo.repo
echo "[myrepo]
name=Network Repository
baseurl=ftp://$myYumServer/pub/localrepo/CentOS/7/0/x86_64
gpcheck=0
enabled=1" > /etc/yum.repos.d/myrepo.repo

yum update

yum repolist

yum --disablerepo "*" --enablerepo "myrepo" list available

setenforce 0

echo "Finished installing CLIENT YUM REPOSITORY"
