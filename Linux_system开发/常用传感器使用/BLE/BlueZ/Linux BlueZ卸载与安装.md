

### 1.卸载

https://www.thelinuxfaq.com/ubuntu/ubuntu-17-04-zesty-/bluez?type=uninstall

```shell
# Uninstall bluez including dependent package
$ sudo apt-get remove --auto-remove bluez 

# Use Purging bluez  including dependent package
$ sudo apt-get purge --auto-remove bluez 

$ sudo dpkg -l | grep bluez
```



### 2.安装

https://www.linuxidc.com/Linux/2017-03/141457.htm

```shell
sudo systemctl stop bluetooth
# 安装依赖包
sudo apt-get update
sudo apt-get install libusb-dev libdbus-1-dev libglib2.0-dev libudev-dev libical-dev libreadline-dev libdbus-glib-1-dev unzip udev 

sudo apt-get install -y bluetooth blueman

# 下载bluez
wget http://www.kernel.org/pub/linux/bluetooth/bluez-5.54.tar.xz
tar xvf bluez-5.54.tar.xz
cd bluez-5.54
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-library
make
sudo make install
# sudo ln -svf /usr/libexec/bluetooth/bluetoothd /usr/sbin/
sudo mv /usr/lib/bluetooth/bluetoothd /usr/lib/bluetooth/bluetoothd.orig # 保存旧文件
sudo ln -s /usr/libexec/bluetooth/bluetoothd /usr/lib/bluetooth/bluetoothd
# sudo install -v -dm755 /etc/bluetooth
# sudo install -v -m644 src/main.conf /etc/bluetooth/main.conf
sudo systemctl daemon-reload
sudo systemctl start bluetooth

bluetoothd --version
5.54
bluetoothctl -v
bluetoothctl: 5.54

# 安装gatttool
sudo cp attrib/gatttool /usr/local/bin/
```



