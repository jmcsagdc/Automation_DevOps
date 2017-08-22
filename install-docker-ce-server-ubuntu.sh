echo "Installing DOCKER CE via repository"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
sudo apt update
#  sudo apt list --upgradeable
#  sudo apt upgrade
sudo apt-cache policy docker-ce
sudo apt-get install -y docker-ce
sudo systemctl status docker
sudo systemctl enable docker
sudo usermod -aG docker ${USER}
echo "DONE with DOCKER CE install. Restart your shell to pick up new group membership."
