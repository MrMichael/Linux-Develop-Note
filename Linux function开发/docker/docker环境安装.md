

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

