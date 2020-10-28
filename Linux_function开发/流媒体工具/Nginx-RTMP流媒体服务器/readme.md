[TOC]



### 一、搭建Nginx-RTMP 直播服务器

[参考](https://blog.csdn.net/huangliniqng/article/details/82469148)

#### 1.安装环境依赖

```shell
mkdir nginx-src
cd nginx-src

# 安装PCRE库
wget https://sourceforge.net/projects/pcre/files/pcre/8.39/pcre-8.39.tar.gz
tar -xzvf pcre-8.39.tar.gz
cd pcre-8.39
./configure
make 
sudo make install
```



#### 2.编译安装nginx库

```shell
sudo apt-get install build-essential
git clone https://github.com/nginx/nginx.git
git clone https://github.com/arut/nginx-rtmp-module.git
cd nginx
git checkout release-1.9.9
vim cfg.sh
	# 填入以下内容
    auto/configure --prefix=/usr/local/nginx \
        --with-pcre=../pcre-8.39 \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --add-module=../nginx-rtmp-module/
chmod 755  cfg.sh
./cfg.sh
make
make install

# 配置nginx服务环境
cd /usr/local/nginx/conf
sudo vim nginx.conf
	# 末尾填入以下内容
	rtmp {
        server {
            listen 1935;
            chunk_size 4096;

            application live {
                live on;
                record off;
            }

            application hls_alic {
                live on;
                hls on;
                hls_fragment 5s;

            }
        }
    }
```



#### 3.使用nginx命令

```shell
# 启动nginx
sudo /usr/local/nginx/sbin/nginx
    # 查看端口
    netstat -ano|grep 1935
# 检查配置文件是否正确
sudo /usr/local/nginx/sbin/nginx -t
# 查看编译选项
sudo /usr/local/sbin/nginx -V
# 重启Nginx
sudo /usr/local/nginx/sbin/nginx -s reload
# 关闭Nginx
sudo /usr/local/nginx/sbin/nginx -s stop
#优雅停止服务
sudo /usr/local/nginx/sbin/nginx -s quit
```



### 二、对服务器推流

```shell
# 安装ffmpeg
sudo apt-get -y install ffmpeg

# 安装gstreamer
sudo apt-get -y install libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio
```



#### 1.通过IP摄像头推流

```shell
# 使用ffmpeg推流
	# 海康ip摄像头
sudo ffmpeg -rtsp_transport tcp -i rtsp://user:passwd@10.56.0.17:554/h264/ch1/sub/av_stream -vcodec copy -an -f flv rtmp://10.55.2.185:1935/live/camera0
	# 其他厂商ip摄像头
sudo ffmpeg -rtsp_transport tcp -i rtsp://192.168.1.19:554/mpeg4  -vcodec copy -an  -f flv rtmp://10.55.2.185:1935/live/camera0

# 使用gstreamer推流
gst-launch-1.0 -e --gst-debug-level=3 rtspsrc location=rtsp://192.168.1.19:554/mpeg4 ! rtph264depay ! h264parse ! tee name=t \
	t. ! queue ! flvmux streamable=true ! rtmpsink sync=false location=rtmp://172.17.0.1/live/camera0 	# stream
```



#### 2.通过视频文件推流

```shell
# 使用ffmpeg推流
sudo ffmpeg -re  -i video.flv -vcodec copy -an -f flv  rtmp://10.55.2.185:1935/live/camera0
```



#### 3.通过usb摄像头推流