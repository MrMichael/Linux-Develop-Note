### 安装golang环境

```shell
# 安装 C 工具
sudo apt-get install bison ed gawk gcc libc6-dev make

cd ~
# 下载go二进制文件并安装
wget https://dl.google.com/go/go1.14.1.linux-arm64.tar.gz
sudo tar -zxvf go1.14.1.linux-arm64.tar.gz -C  /usr/local

# 设置环境变量GOROOT
sudo vim /etc/profile
	# 在末尾加入
	export GOROOT=/usr/local/go
	export PATH=$PATH:$GOROOT/bin
source /etc/profile

# 测试go
go version
```



### 创建golang工作空间

```shell
cd ~ && mkdir goworkspace
cd goworkspace &&  mkdir bin src
# 设置环境变量GOPATH、GOBIN
sudo vim /etc/profile
	# 在末尾加入
	export GOPATH=/home/admin/goworkspace
	export GOBIN=/home/admin/goworkspace/bin
	export GOPROXY=https://mirrors.aliyun.com/goproxy/
source /etc/profile
```



### 登录用户自动配置golang环境

```shell
su admin
vim ~/.bashrc
	# 在末尾添加
	source /etc/profile

sudo su
vim ~/.bashrc
	# 在末尾添加
	source /etc/profile
```



