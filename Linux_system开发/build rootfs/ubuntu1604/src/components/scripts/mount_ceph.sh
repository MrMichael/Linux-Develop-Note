ip=${1}

# 挂载 ceph-fuse
time=`date +%s`
mv /data/edgebox/remote /data/edgebox/remote_$time
mkdir -p /data/edgebox/remote
ceph-fuse -m ${ip}:6789 /data/edgebox/remote