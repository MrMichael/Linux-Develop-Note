#!/bin/bash

# required sudo apt-get install uml-utilities

#UTUN=$1
IP=$4
#IP="10.201.1.6"
MASK="16"

VPNDIR="/etc/openvpn/client"
TAP_FILE="${VPNDIR}/last_tap"

OLD_VTAP=`cat ${TAP_FILE}`
if [ "x${OLD_VTAP}" != "x" ];then
	/usr/sbin/tunctl -d ${OLD_VTAP}
fi

/usr/sbin/tunctl -b > ${TAP_FILE}
VTAP=`cat ${TAP_FILE}`

/sbin/ip link set dev ${VTAP} up mtu 1500
/sbin/ip addr add dev ${VTAP} ${IP}/${MASK} broadcast 10.201.255.255
