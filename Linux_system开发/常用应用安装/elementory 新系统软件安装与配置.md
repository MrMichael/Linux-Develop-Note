[TOC]



## 1.安装chrome
```shell
sudo wget https://repo.fdzh.org/chrome/google-chrome.list -P /etc/apt/sources.list.d/
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub  | sudo apt-key add -
sudo apt-get update
sudo apt-get install google-chrome-stable
```



## 2.安装shadowsocks

```shell
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:hzwhuang/ss-qt5
 
# 将源中的bionic改成xenial
sudo vim /etc/apt/sources.list.d/hzwhuang-ubuntu-ss-qt5-bionic.list
    #修改为：deb http://ppa.launchpad.net/hzwhuang/ss-qt5/ubuntu xenial main
sudo apt-get update
sudo apt-get install shadowsocks-qt5
```



## 3.安装elementory os deepin相关软件

https://elementaryos.cn/storage.html

```shell
sudo wget -O - http://package.elementaryos.cn/bionic/key/package.gpg.key | sudo apt-key add -
sudo vim /etc/apt/sources.list
    # 添加：deb http://package.elementaryos.cn/bionic/ bionic main
sudo apt-get update
sudo apt-get install deepin.cn.com.winrar
sudo apt-get install baidunetdisk
sudo apt-get install deepin.com.wechat
sudo apt-get install deepin.com.weixin.work
sudo apt-get install netease-cloud-music
sudo apt-get install sogoupinyin
```

- 部分软件重启生效
- deepin.com.wechat、deepin.com.weixin.work中文字体显示异常问题：
  - 原因：软件安装包中没有fonts文件
  - 解决办法：将window系统下C:\Windows\Fonts的所有文件复制到/home/username/.deepinwine/Deepin-WXWork/drive_c/windows/Fonts/目录下（wechat同理），然后重启软件。



## 4.安装snap相关软件

https://snapcraft.io/

```shell
sudo apt install snapd snapd-xdg-open
sudo snap install sublime-text --classic
sudo snap install code --classic
sudo snap install spotify
sudo snap install gnome-system-monitor
```



## 5.安装office办公软件

```shell
sudo apt-get install libreoffice-calc
sudo apt-get install libreoffice-writer
sudo apt-get install libreoffice-impress
```



## 6.安装QQ

https://im.qq.com/linuxqq/download.html

```shell
wget https://qd.myapp.com/myapp/qqteam/linuxQQ/linuxqq_2.0.0-b1-1024_amd64.deb
sudo dpkg -i linuxqq_2.0.0-b1-1024_amd64.deb
```



## 7.安装virtualbox

```shell
sudo apt-get install virtualbox
```



## 8.安装pdf阅读器

```shell
# 安装okular
sudo apt-get install okular

# 安装福昕pdf
wget http://cdn01.foxitsoftware.com/pub/foxit/reader/desktop/linux/2.x/2.4/en_us/FoxitReader2.4.1.0609_Server_x64_enu_Setup.run.tar.gz
tar -xvf FoxitReader*.tar.gz
sudo ./FoxitReader.enu.setup.2.4.1.0609\(r08f07f8\).x64.run
```



## 9.安装filezilla

```shell
sudo apt-get install filezilla
```



## 10.安装typora

```shell
wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
# add Typora's repository
sudo add-apt-repository 'deb https://typora.io/linux ./'
sudo apt-get update
# install typora
sudo apt-get install typora
```



## 11.elementory os 自带软件启动

```shell
io.elementary.xxx
```



## 12.安装必要服务

```shell
sudo apt-get install openssh-server
    sudo /etc/init.d/ssh start  
    
sudo apt-get install git
	git config --global user.email "youremail@example.com"
	git config --global user.name "Your Name"
	cd ~/.ssh
	ssh-keygen -t rsa -C "youremail@example.com" 
```


​    



