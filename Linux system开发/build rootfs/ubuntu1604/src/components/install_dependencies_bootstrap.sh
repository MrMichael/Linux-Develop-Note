#! /bin/bash
:<<!
if [ "${UID}" -ne 0 ]
then
  echo -e "\033[31m please use root privilege to run this script \033[0m"
  exit 1
fi
!
export LC_ALL="C.UTF-8"

#read -p "Please input master vpn server ip:" VPN_IP
#echo "${VPN_IP} vpnserver.jiangxingai.com" >> /etc/hosts

ARCH=`uname -m`
OPENVPN_FILES="/app/openvpn_files"
BOOTSTRAP_DIR="/app/bootstrap"
DEPENDDIR="./dependencies"
TMP_CONFIG_FILES="./tmp_config_files"
worker_packages=(adm monitor)

apt-get -y install unzip usbutils udev psmisc v4l-utils
apt-get -y install libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev # python PIL requirements

mkdir -p $TMP_CONFIG_FILES
sudo unzip -o /app/keys.zip -d $TMP_CONFIG_FILES
mkdir -p $OPENVPN_FILES
mv ./tmp_config_files/app/openvpn_files/* $OPENVPN_FILES
mv ./tmp_config_files/etc/ceph /etc/


## Config docker-ce

cp ./components/dependencies/docker.service /lib/systemd/system/docker.service
#systemctl daemon-reload
mkdir -p /etc/docker/
cp ./components/dependencies/daemon.json /etc/docker/daemon.json
#service docker restart


## install pip, pip3
echo -e "\033[34m installing pip, pip3 \033[0m"
case "$ARCH" in
  aarch64) add-apt-repository universe;; # tested on tx2
esac
apt-get -y update
apt install -y python-pip python3-pip

## install monitor-tools
curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
apt-get update
apt install -y telegraf

pip3 install setuptools --upgrade
## Install worker packages
for p in ${worker_packages[@]}; do
  pip3 install -i http://pypi.jiangxingai.com/simple/ --trusted-host pypi.jiangxingai.com edge_box_${p}
done
pip3 install -i http://pypi.jiangxingai.com/simple/ --trusted-host pypi.jiangxingai.com mongo-connector
pip3 install pillow

## install openvpn
apt-get -y install openvpn
apt-get -y install uml-utilities
mkdir -p /etc/openvpn/client/keys

## Install mongodb
echo -e "\033[34m installing mongodb \033[0m"
mkdir -p mongo
pushd mongo
arch_tag=arm64
wget "https://repo.mongodb.org/apt/ubuntu/dists/xenial/mongodb-org/4.0/multiverse/binary-${arch_tag}/mongodb-org-server_4.0.5_${arch_tag}.deb"
wget "https://repo.mongodb.org/apt/ubuntu/dists/xenial/mongodb-org/4.0/multiverse/binary-${arch_tag}/mongodb-org-tools_4.0.5_${arch_tag}.deb"
wget "https://repo.mongodb.org/apt/ubuntu/dists/xenial/mongodb-org/4.0/multiverse/binary-${arch_tag}/mongodb-org-shell_4.0.5_${arch_tag}.deb"
popd
dpkg -i -R ./mongo
apt-get -f -y install


## install supervisor
mkdir -p /etc/supervisor
mkdir -p /data/logs/supervisor
apt-get install -y supervisor


# install ceph-fuse
apt-get install -y libgoogle-perftools4 libibverbs1 libtcmalloc-minimal4

wget -P ./components/dependencies/ceph/ http://repo.jiangxingai.com/project-archive/ceph-deb/ceph-fuse_12.2.11-1_arm64.deb
dpkg -i ./components/dependencies/ceph/ceph-fuse_12.2.11-1_arm64.deb  
apt-get -f -y install

rm -rf  /tmp_config_files
