[TOC]



#### 1.无法ping www.baidu.com

添加dns 解析

```shell
sudo rm /etc/resolv.conf
# sudo touch /etc/resolv.conf
# echo "nameserver 8.8.8.8" > /etc/resolv.conf
sudo vim /etc/resolv.conf
	nameserver 8.8.8.8
ping www.baidu.com
```



#### 2.Failed to start Network Time Synchronization

[How To Set Up Time Synchronization on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-time-synchronization-on-ubuntu-18-04)

系统时间不同步会导致apt update出错

```shell
sudo apt-get update
sudo apt install ntp
sudo systemctl restart ntp
sudo timedatectl
date
```

- 需要先确保域名解析正常。



#### 3.调整系统ext4分区大小

```shell
sudo resize2fs /dev/mmcblk2p8
```

##### 1) The filesystem is already 14034924 (1k) blocks long.  Nothing to do!

原因：分区表设置问题，分区表在rootfs后设置了userdata分区





3.systemd-gpt-auto-generator: Failed to dissect: Input/output error