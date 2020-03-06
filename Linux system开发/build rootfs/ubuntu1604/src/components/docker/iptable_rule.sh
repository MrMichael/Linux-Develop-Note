#!/bin/bash

HOST_IP=${1}
HOSTS_FILE=${2}
ADM_PORT=${3}

#if [ "x${HOST_IP}" -eq "x" ]; then
#    echo "required hostip"
#    exit 1
#fi

DOCKER_IP=`echo ${HOST_IP} | awk -F'.' '{print "172."$3"."$4".1/24"}'`

# 0. modify docker daemon.json for bip
python3 bootstrap/docker/modify_docker_daemon.py "${DOCKER_IP}" "/etc/docker/daemon.json"
sudo systemctl restart docker.service

# 1. add other hosts as docker gw
python3 bootstrap/docker/add_router.py ${HOST_IP} ${HOSTS_FILE} ${ADM_PORT}

# 2. sysctl -p enable ipv4 forward
if [ `sysctl -p | grep "net.ipv4.ip_forward = 1" | wc -l` -ne 1 ]; then
    sudo echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p
fi

# 3. add iptable snat rule 
#iptables -t nat -F POSTROUTING
#iptables -t nat -A POSTROUTING -s ${DOCKER_IP} ! -d 172.0.0.0/8 -j MASQUERADE
iptables -P FORWARD ACCEPT
