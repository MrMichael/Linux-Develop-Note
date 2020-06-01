#! /bin/bash
register_server=as.jiangxingai.com
register_port=8400

OS_VER=OS-VER

echo -e '\033[36m Initializing system... \033[0m'

apt-get update
apt-get upgrade -y

echo -e '\033[36m installing packages... \033[0m'
apt-get install -y \
  sudo \
  kmod \
  net-tools \
  iputils-ping \
  bridge-utils  

apt-get install -y \
  openssh-server \
  tmux \
  vim \
  git

# install docker
echo -e '\033[36m installing Docker... \033[0m'
apt-get update
apt-get upgrade -y
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

add-apt-repository \
   "deb [arch=arm64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get upgrade -y
apt-get install -y containerd.io  libltdl7  iptables  libnfnetlink0 
wget http://repo.jiangxingai.com/container/docker-prod-arm64v8.tar.gz
tar -zxvf docker-prod-arm64v8.tar.gz -C .
cd ubuntu-xenial
tar -zxvf docker-ce_0.0.0-20190127050414-4e64113-0~ubuntu-xenial.tar.gz -C .
dpkg -i docker-ce-cli_0.0.0-20190127050414-4e64113-0~ubuntu-xenial_arm64.deb
dpkg -i docker-ce_0.0.0-20190127050414-4e64113-0~ubuntu-xenial_arm64.deb
#apt-get install -y docker-ce docker-ce-cli containerd.io
cd ..
rm -rf docker-prod-arm64v8.tar.gz ubuntu-xenial


:<<!
# install rkmpp
apt-get update \
&& apt-get install -y \
  gcc \
  autoconf \
  pkg-config \ 
  autopoint \
  libtool \
  bison \
  flex \
  gtk-doc-tools \
  libperl-dev libgtk2.0-dev \
  librtmp-dev freeglut3 freeglut3-dev \
  libjpeg-dev \
  cmake

wget https://github.com/hebizz/privacy-guide/releases/download/111/rkmpp.1.tar.gz
tar -zxvf rkmpp.1.tar.gz -C .
cp -r rkmpp       usr/local/
sed -i 's/video2/video0/g'   usr/local/rkmpp/bin/run.sh
cp  components/mpp.conf   etc/ld.so.conf.d/
cd  usr/local/rkmpp/lib/
rm -f *.so.0
ldconfig -v
cd -
rm -rf rkmpp
rm -rf rkmpp.1.tar.gz
!
## update release info and motd configs
echo -e '\033[36m -- update release info and motd configs... \033[0m'
sudo sed -i 's/EDGE-VERSION/'${OS_VER}'/g' components/issue
sudo sed -i 's/EDGE-VERSION/'${OS_VER}'/g' components/issue.net
sudo sed -i 's/EDGE-VERSION/'${OS_VER}'/g' components/lsb-release
#sudo cp components/issue                /etc/issue
#sudo cp components/issue.net            /etc/issue.net
#sudo cp components/lsb-release          /etc/lsb-release
sudo cp components/motd/00-header       /etc/update-motd.d/00-header
sudo cp components/motd/10-help-text    /etc/update-motd.d/10-help-text


## update network configs
#echo -e '\033[36m -- updating network configurations... \033[0m'
#sudo cp components/interfaces   /etc/network/interfaces
#sudo systemctl restart networking
#### let system register eth0 with `auto` first, then change to `allow-hotplug` option
#sudo sed -i 's/auto/allow-hotplug/g' /etc/network/interfaces
sudo sed -i 's/5min/10sec/g' /etc/systemd/system/network-online.target.wants/networking.service
sudo sed -i 's/300/10/g' /etc/dhcp/dhclient.conf 


## register online
echo -e '\033[36m -- registering device... \033[0m'
sudo cp components/hostname     /etc/hostname
sudo cp components/hosts        /etc/hosts


##  timezone configs
echo -e '\033[36m --timezone  configs...\033[0m'
sudo mkdir -p  /usr/share/zoneinfo/Asia
sudo cp        components/timezone      /etc/timezone
sudo cp        components/localtime     /usr/share/zoneinfo/Asia/Shanghai
sudo rm -f     /etc/localtime
sudo ln -s     /usr/share/zoneinfo/Asia/Shanghai   /etc/localtime



bash ./components/install_dependencies_bootstrap.sh  

echo -e '\033[32m Initialize finished! \033[0m'
## add default users
echo -e '\033[36m creating accounts... \033[0m'
useradd -s '/bin/bash' -m -G adm,sudo admin
echo -e '\033[31m -- set password for admin: \033[0m'
passwd admin
echo -e '\033[31m -- set password for root: \033[0m'
passwd root





#exit
