#! /bin/bash 
register_server=as.jiangxingai.com
register_port=8400

echo -e '\033[36m network configs...\033[0m'
cp /components/interfaces  /etc/network/interfaces
systemctl restart networking
echo " " >> /etc/network/interfaces
echo "auto usb0" >> /etc/network/interfaces
echo "iface usb0 inet dhcp" >> /etc/network/interfaces 


echo -e '\033[36m hostname configs... \033[0m'
mac_addr=`ifconfig eth0 | grep HWaddr | awk '{print $5}'`
ping -c 2 $register_server
if [ $? -eq 0 ]; then
  ret=`curl $register_server:$register_port/register${DEBUG}?mac=$mac_addr`
  if [ ${#ret} -gt 8 ]; then
    echo -e '\033[31m [FAIL] this device has already been activated \033[0m'
  else
    hostname="edgenode-"$ret
    echo -e '\033[36m [SUCC] flashing with '${hostname}'... \033[0m'
    sudo sed -i 's/edgenode/'${hostname}'/g' /etc/hostname
    sudo sed -i 's/edgenode/'${hostname}'/g' /etc/hosts
  fi
else
  echo -e '\033[31m [FAIL] cannot connect to register server \033[0m'
fi

sudo resize2fs /dev/mmcblk0p5


export LC_ALL="C.UTF-8"

read -p "Please input master vpn server ip:" VPN_IP
echo "${VPN_IP} vpnserver.jiangxingai.com" >> /etc/hosts

ARCH=`uname -m`
OPENVPN_FILES="/app/openvpn_files"
BOOTSTRAP_DIR="/app/bootstrap"
DEPENDDIR="./dependencies"


tag="arm64v8-cpu"
images=(base/device-pipe base/device-pipe-bitrate base/device-pipe-gstreamer)
versions=(0.1.1 0.1.0 0.1.0)

for index in ${!images[*]}; do 
  image="registry.jiangxingai.com:5000/${images[$index]}:${tag}-${versions[$index]}"
  echo $image
  docker pull $image
done


docker pull budry/cadvisor-arm:latest


docker pull registry.jiangxingai.com:5000/nginx-rtmp:${tag}-0.1.0

systemctl stop docker
systemctl disable docker


## Config openvpn
mkdir -p ${OPENVPN_FILES}
mkdir -p /etc/openvpn/client/keys/
cp ${DEPENDDIR}/client.ovpn /etc/openvpn/client.ovpn
cp ${DEPENDDIR}/up.sh /etc/openvpn/client/
cp ${DEPENDDIR}/down.sh /etc/openvpn/client/
cp ${DEPENDDIR}/openvpn.conf /etc/supervisor/conf.d
cp ${OPENVPN_FILES}/client.crt /etc/openvpn/client/keys/client.crt
cp ${OPENVPN_FILES}/client.key /etc/openvpn/client/keys/client.key
cp ${OPENVPN_FILES}/client.csr /etc/openvpn/client/keys/client.csr
cp ${OPENVPN_FILES}/ca.crt /etc/openvpn/client/keys
cp ${OPENVPN_FILES}/ta.key /etc/openvpn/client/keys

supervisorctl reload
supervisorctl restart openvpn

# if success remove .bak else restore
sleep 5
if [ `supervisorctl  status openvpn | awk '{print $2}'` != 'RUNNING' ]; then
    mv /etc/openvpn/client/keys /etc/openvpn/client/keys.failed
    mv /etc/openvpn/client/keys.bak /etc/openvpn/client/keys
    supervisorctl restart openvpn
fi
supervisorctl status openvpn


mkdir -p $BOOTSTRAP_DIR
mv * $BOOTSTRAP_DIR

bash /app/bootstrap/scripts/renew_vpn.sh
python3 /app/bootstrap/scripts/register.py
supervisorctl status

read -p "Reboot is needed. Do you want to reboot now? [Y/n]" YN
if [[ $YN == "y" || $YN == "Y" || $YN == "" ]]
then
    reboot
fi










