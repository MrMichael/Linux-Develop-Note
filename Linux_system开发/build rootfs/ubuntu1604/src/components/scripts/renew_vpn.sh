if [ -f "/app/uuid" ]
then
  UUID=`cat /app/uuid`
else
  UUID=`cat /proc/sys/kernel/random/uuid`
  echo $UUID > /app/uuid
fi

# openvpn setup
curl "http://10.201.0.1:1195/configuration?uid=${UUID}" -o ${UUID}.tgz

mv /etc/openvpn/client/keys /etc/openvpn/client/keys.bak
mkdir -p /etc/openvpn/client/keys
mkdir -p /tmp/openvpn/keys
tar -zxvf ${UUID}.tgz -C /tmp/openvpn/keys
mv /tmp/openvpn/keys/${UUID}/* /etc/openvpn/client/keys
supervisorctl restart openvpn