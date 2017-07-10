#!/bin/sh

yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum makecache fast
yum install -y docker-ce
systemctl start docker
systemctl enable docker
docker run hello-world

# Install docker-machine command
curl -L https://github.com/docker/machine/releases/download/v0.12.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && chmod +x /tmp/docker-machine && sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin

# Add to profile
echo "export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin" >> /root/.bashrc

# Grab command-line completion from github
wget https://raw.githubusercontent.com/docker/machine/master/contrib/completion/bash/docker-machine-prompt.bash
wget https://raw.githubusercontent.com/docker/machine/master/contrib/completion/bash/docker-machine-wrapper.bash
wget https://raw.githubusercontent.com/docker/machine/master/contrib/completion/bash/docker-machine.bash

# Put them where they should be. One of two potential locations.
mv docker-machine* /etc/bash_completion.d/

# Add command-line completion tools
source /etc/bash_completion.d/docker-machine-prompt.bash
export PS1='[\u@\h \W$(__docker_machine_ps1)]\$'

# Add to profile
echo "source /etc/bash_completion.d/docker-machine-prompt.bash
export PS1='[\u@\h \W$(__docker_machine_ps1)]\$'" >> /root/.bashrc

echo "DONE!!!"
