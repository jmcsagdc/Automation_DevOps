yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum makecache fast
yum install -y docker-ce
systemctl start docker
systemctl enable docker
docker run hello-world

echo "DONE!!!"
