

#### 1.安装及配置netplan

```shell
# install netplan
sudo apt-get update
sudo apt-get install udev
sudo apt-get install netplan
sudo apt-get install netplan.io

# 新建配置文件，填入
sudo vim /etc/netpaln/00-installer-config.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
    usb0:
      dhcp4: true
      dhcp4-overrides:
      	route-metric: 101
      
      
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      dhcp6: no
      addresses: [10.55.3.183/24]
      gateway4: 10.55.3.253
      nameservers:
        addresses: [114.114.114.114, 8.8.8.8]
    usb0:
      dhcp4: true
      dhcp4-overrides:
         route-metric: 101
      
# 测试配置文件
sudo netplan try
      
# 应用netplan配置文件
sudo netplan apply
```



#### 2.停止networking.service服务

```shell
# 清空/etc/network/interfaces文件的内容

sudo systemctl stop networking.service
sudo systemctl disable networking.service
```



#### 3.查看网络相关服务的系统启动

```shell
$ systemctl list-units --all |grep network
  networkd-dispatcher.service  	 loaded    active     running         Dispatcher daemon for systemd-networkd             
  networking.service 						loaded    inactive   dead            Raise network interfaces                           
  systemd-networkd-wait-online.service   loaded    active     exited          Wait for Network to be Configured                  
  systemd-networkd.service        loaded    active     running         Network Service                                    
  network-online.target                  loaded    active     active          Network is Online                                  
  network-pre.target 						loaded    inactive   dead            Network (Pre)                                      
  network.target 								loaded    active     active          Network           
```



#### 4.网口插拔的状态变化

```shell
$ systemctl status systemd-networkd.service
● systemd-networkd.service - Network Service
   Loaded: loaded (/lib/systemd/system/systemd-networkd.service; enabled-runtime
   Active: active (running) since Tue 2020-08-18 14:48:39 CST; 2min 44s ago
     Docs: man:systemd-networkd.service(8)
 Main PID: 153 (systemd-network)
   Status: "Processing requests..."
    Tasks: 1 (limit: 2396)
   CGroup: /system.slice/systemd-networkd.service
           └─153 /lib/systemd/systemd-networkd

Aug 18 14:50:37 edgenode systemd-networkd[153]: eth0: Lost carrier
Aug 18 14:50:37 edgenode systemd-networkd[153]: eth0: DHCP lease lost
Aug 18 14:50:57 edgenode systemd-networkd[153]: eth0: Gained carrier
Aug 18 14:50:57 edgenode systemd-networkd[153]: eth0: DHCPv4 address 10.53.3.170
Aug 18 14:50:57 edgenode systemd-networkd[153]: eth0: Configured
Aug 18 14:51:10 edgenode systemd-networkd[153]: eth0: Lost carrier
Aug 18 14:51:10 edgenode systemd-networkd[153]: eth0: DHCP lease lost
Aug 18 14:51:19 edgenode systemd-networkd[153]: eth0: Gained carrier
Aug 18 14:51:22 edgenode systemd-networkd[153]: eth0: DHCPv4 address 192.168.10.12
Aug 18 14:51:22 edgenode systemd-networkd[153]: eth0: Configured
```

