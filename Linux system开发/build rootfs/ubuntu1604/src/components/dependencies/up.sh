#!/bin/bash

# required sudo apt-get install uml-utilities

#UTUN=$1
IP=$4
#IP="10.201.1.6"
MASK="16"

VPNDIR="/etc/openvpn/client"
TAP_FILE="${VPNDIR}/last_tap"

if [ -f ${TAP_FILE} ]; then
	VTAP=`cat ${TAP_FILE}`
	/usr/sbin/tunctl -d ${VTAP}
fi

echo "" > ${TAP_FILE}
