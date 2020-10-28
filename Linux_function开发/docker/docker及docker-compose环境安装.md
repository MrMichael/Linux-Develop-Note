### 安装docker

```shell
# 更新软件源
$ sudo apt-get update

# Install packages to allow apt to use a repository over HTTPS
$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# add Docker’s official GPG key
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# 验证系统拥有指纹数据9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88
$ sudo apt-key fingerprint 0EBFCD88

# 添加远程仓库到软件源，稳定版、测试版或轻量版 x86_64/amd64:[arch=amd64], arm64:[arch=arm64],armhf:[arch=armhf]
$ sudo add-apt-repository \
   "deb [arch=arm64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
   
$ sudo apt-get update

$ sudo apt-get install docker-ce docker-ce-cli containerd.io
```



### 安装docker-compose

```shell
sudo apt-get update
# 安装依赖环境
sudo apt-get install py-pip python-dev libffi-dev openssl-dev gcc libc-dev make

# 基于ubuntu x86_64
# 下载Docker Compose的当前稳定版本
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version

# 基于ubuntu ARM
	# 由于官方并没有发布ARM架构的docker-compose安装文件，需要采用pip来安装
sudo apt-get install -y python3 python3-pip
sudo apt-get install libffi-dev
sudo pip3 install docker-compose
# 拷贝python3.6的dist-packages文件夹到docker的工作目录下

# 测试安装
sudo docker-compose version
```

