#! /bin/bash

HOST_IP=${1}
HOSTS_FILE=${2}
ADM_PORT=${3}
MASTER_IP=${4}
HOSTNAME=${5}


if [ "${UID}" -ne 0 ]
then
  echo -e "\033[31m please use root privilege to run this script \033[0m"
  exit 1
fi

export LC_ALL="C.UTF-8"

ARCH=`uname -m`
PKG="/app/platform/pkg"
INIT_MARK_FILE="/app/init"

if [ -f $INIT_MARK_FILE ]
then
  echo -e "\033[31m worker already inited \033[0m"
  exit 1
fi

touch $INIT_MARK_FILE

hostnamectl set-hostname ${HOSTNAME}
echo "127.0.0.1 ${HOSTNAME}" >> /etc/hosts

## Config monitor-tools
sed -i "s/EDGEBOX_SED_MASTER_IP/${MASTER_IP}/" /app/bootstrap/platform/conf/telegraf.conf
cp /app/bootstrap/platform/conf/telegraf.conf /etc/telegraf/telegraf.conf
systemctl restart telegraf
systemctl enable telegraf

## Config worker packages
sed -i "s/EDGEBOX_SED_MASTER_IP/${MASTER_IP}/" /app/bootstrap/platform/settings/worker/adm.json
sed -i "s/EDGEBOX_SED_MASTER_IP/${MASTER_IP}/" /app/bootstrap/platform/settings/worker/monitor.json
sed -i "s/EDGEBOX_SED_HOST_IP/${HOST_IP}/" /app/bootstrap/platform/settings/worker/adm.json
sed -i "s/EDGEBOX_SED_HOST_IP/${HOST_IP}/" /app/bootstrap/platform/settings/worker/monitor.json

# config edgebox settings
mkdir -p ${PKG}
cp -r /app/bootstrap/platform/settings ${PKG}

# config database
mkdir -p /data/database/mongo/adm/data
cp /app/bootstrap/platform/conf/database.conf /data/database/mongo/adm/base.conf

## Config supervisor
cp -r /app/bootstrap/platform/conf/supervisor/* /etc/supervisor
if [ `ps -ef | grep /usr/bin/supervisord | grep -v grep | wc -l` -eq 1 ]; then
    supervisorctl reread
    supervisorctl update
else
    systemctl enable supervisor
    systemctl restart supervisor
fi

sleep 1
mongo --eval "rs.initiate()"
supervisorctl restart adm_mongo_upload

case "$ARCH" in
    x86_64) tag="x8664-cpu";;
    aarch64) tag="arm64v8-cpu";;
esac

service docker restart
docker run --name edgebox-rtmp-server -p 1935:1935 -d --restart unless-stopped registry.jiangxingai.com:5000/nginx-rtmp:${tag}-0.1.0

# config docker iptable
# sh /app/bootstrap/docker/iptable_rule.sh ${HOST_IP} ${HOSTS_FILE} ${ADM_PORT}
