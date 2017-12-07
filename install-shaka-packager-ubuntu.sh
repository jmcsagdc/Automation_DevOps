echo "BEGIN PACKAGER INSTALL"
echo "DO: apt-get update and install some utilities"
sudo apt-get update
sudo apt-get install build-essential curl git python

echo "DO: Git clone depot_tools"
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

echo "DO: Export your cloned ~/depot_tools and add it to ~/.bashrc"
export PATH="$PATH:/home/$USER/depot_tools"
echo 'export PATH="$PATH:/home/$USER/depot_tools"' >> .bashrc

echo "CONFIRM that your ~/.bashrc has an export of your ~/depot_tools directory for the compilation process"
tail .bashrc

echo "DO: Make ~/shaka_packager directory and cd to it."
mkdir shaka_packager && cd shaka_packager
echo "DO: gclient config https://www.github.com/google/shaka-packager.git --name=src --unmanaged"
gclient config https://www.github.com/google/shaka-packager.git --name=src --unmanaged



## DO STUFF ##
echo "DO: Adding path to packager binary"
PATH="$PATH:/home/$USER/shaka_packager/src/out/Release/"
echo 'export PATH="$PATH:/home/$USER/shaka_packager/src/out/Release/"' >> ~/.bashrc
