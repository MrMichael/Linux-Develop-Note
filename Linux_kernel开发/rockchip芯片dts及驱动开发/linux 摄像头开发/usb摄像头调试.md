

### 一、常用操作

#### 1.linux查看usb camera设备

```shell
sudo apt-get install v4l-utils
v4l2-ctl --list-device

ls /dev/video*
```



#### 2.安装应用程序显示摄像头捕捉到的视频

1）使用应用程序camorama

```shell
sudo apt-get install camorama
camorama

#如果使用Xshell进行ssh远程访问，会提醒安装Xmanager软件显示视频流
```

- Xmanager是一个运行于MS Windows平台上的高性能的X window服务器。可以在本地PC上同时运行Unix/Linux和Windows图形应用程序。

- Xmanager可以将PC变成X Windows工作站，它可以无缝拼接到UNIX 应用程序中。在UNIX/Linux和Windows网络环境中，Xmanager 是最好的连通解决方案。

  ![](https://upload-images.jianshu.io/upload_images/15877540-710852b2c492c35c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2）使用应用程序茄子（cheese）

```shell
sudo apt-get install cheese
cheese

#不支持ssh远程显示
```

