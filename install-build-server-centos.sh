# Install Build Server

yum -y install rpm-build
mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros
cat .rpmmacros

yum -y install yum-utils

perl -pi -e 's|enabled=0|enabled=1|g' /etc/yum.repos.d/CentOS-Sources.repo
cat /etc/yum.repos.d/CentOS-Sources.repo | grep enabled

echo "http://vault.centos.org/7.2.1511/os/Source/SPackages/" >> CentOS-Source-Repo-URL

cd /root/rpmbuild/SOURCES/

# From digital ocean
yum groupinstall -y "Development Tools"

# From RedHat (may be in rpm-build)
yum install -y redhat-rpm-config

echo "make and gcc should already be installed. confirm:"
rpm -qa | grep make
rpm -qa | grep gcc

