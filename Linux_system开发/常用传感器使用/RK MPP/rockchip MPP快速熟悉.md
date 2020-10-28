[TOC]



### 一、MPP 简介

Media Process Platform(简称 MPP) 是适用于瑞芯微芯片系列的通用媒体处理软件平台。

该平台对应用软件屏蔽了芯片相关的复杂底层处理, 其目的是为了屏蔽不同芯片的差异, 为使用者提供统一的视频媒体处理接口(Media Process Interface, 缩写 MPI)。

#### 1.MPP的功能

- 视频解码：H.265 / H.264 / H.263 / VP9 / VP8 / MPEG-4 / MPEG-2 / MPEG-1 / VC1 / MJPEG 压缩格式的流媒体【码流数据】
- 视频编码：H.264 / VP8 / MJPEG 压缩格式的视频文件【图像数据】
- 视频处理：视频拷贝，缩放，色彩空间转换，场视频解交织(Deinterlace)。



#### 2.MPP系统架构

![](https://img2018.cnblogs.com/blog/1279278/201812/1279278-20181209103406454-531110161.png)

- 硬件层
  - 硬件层是瑞芯微系列芯片平台的视频编解码硬件加速模块, 包括 VPU, rkvdec, rkvenc 等不同类型,
    不同功能的硬件加速器。

- 内核驱动层
  - Linux 内核的编码器驱动（vcodec_service）、VPU驱动（vpu_service），以及相关的 mmu, 内存, 时钟, 电源管理模块等。

- MPP层
  - MPP层屏蔽了不同操作系统和不同芯片平台的差异，为使用者提供统一的MPI接口，包括：
    - HAL模块
    - OSAL模块
    - MPI模块
    - 视频编解码模块（video decoder、video encoder）
    - 视频处理模块（video process）

- 操作系统层
  - MPP 用户态的运行平台,如 Android 以及 Debian 等 Linux 发行版

- 应用层
  - MPP 层通过 MPI 对接各种中间件软件, 如 OpenMax, ffmpeg 和 gstreamer, 或者直接对接客户的上
    层应用。



#### 3.平台支持

- 硬件平台支持
  - 支持瑞芯微主流的各种系列芯片平台:
    - RK3188 系列, RK3288 系列, RK3368 系列, RK3399 系列
    - RK30xx 系列, RK312x 系列芯片,RK322x 系列芯片, RK332x 系列
    - RV1108 / RV1107 系列

- 软件平台支持
  - MPP 支持在各种版本的 Android 平台和纯 Linux 平台上运行。
  - 支持瑞芯微 Linux 内核 3.10 和 4.4 版本, 需要有 vcodec_service 设备驱动支持以及相应的 DTS 配置
    支持。





### 二、MPI 接口

MPI(Media Process Interface)是 MPP 提供给用户的接口,用于提供硬件编解码功能,以及一些必要的相关功能。

#### 1.MPI接口数据结构

MPI 接口使用的主要数据结构

![](https://upload-images.jianshu.io/upload_images/15877540-bdbe8536aef7787f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- MppMem：C 库 malloc 内存的封装。
- MppBuffe：硬件用的 dmabuf 内存的封装。
- MppPacket ：一维缓存封装, 可以从 MppMem 和 MppBuffer 生成, 主要用于表示码流数据。
  - 码流：视频图像经过编码压缩后在单位时间内的数据流量，应用于流媒体服务器。
- MppFrame ：二维帧数据封装,可 以从 MppMem 和 MppBuffer 生成, 主要用于表示图像数据。
- MppMeta 和 MppTask ：输入输出用任务的高级组合接口,可以支持指定输入输出方式等复杂使用方
  式, 较少使用。



#### 2.MPI 接口使用

MPI 是通过 C 结构里的函数指针方式提供给用户, 用户可以通过 MPP 上下文结构MppCtx 与 MPI 接口结构 MppApi 组合使用来实现解码器与编码器的功能。

- 操作 MppCtx 接口
  - mpp_create，mpp_init，mpp_destroy
- 真正的编码与解码过程是通过调用 MppApi 结构体里内的函数指针来实现。
  - 解码
    - 输 入 码 流 ：decode_put_packet
      - 按帧输入或者按长度输入，默认可以接收 4 个输入码流包在处理队列中。
    - 输 出 图 像：decode_get_frame
  - 编码
    - 输 入 图像 ：encode_put_frame
    - 输 出 码流：encode_get_packet

![](https://upload-images.jianshu.io/upload_images/15877540-f7164c9988bb3706.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



### 三、MPP 库编译与使用

#### 1.下载编译MPP 库

```shell
$ git clone -b release https://github.com/rockchip-linux/mpp.git
# linux 平台编译，假设处理器结构为aarch64
$ cd mpp/build/linux/aarch64
$ sudo apt-get -y install cmake
$ bash make-Makefiles.bash
$ make -j4
$ sudo make install

$ tree -L 2
.
├── arm.linux.cross.cmake
├── CMakeCache.txt
├── CMakeFiles
│   ├── 3.10.2
│   ├── cmake.check_cache
│   ├── CMakeDirectoryInformation.cmake
│   ├── CMakeError.log
│   ├── CMakeOutput.log
│   ├── CMakeTmp
│   ├── feature_tests.bin
│   ├── feature_tests.c
│   ├── feature_tests.cxx
│   ├── Makefile2
│   ├── Makefile.cmake
│   ├── progress.marks
│   └── TargetDirectories.txt
├── cmake_install.cmake
├── Makefile
├── make-Makefiles.bash
├── mpp
│   ├── base
│   ├── CMakeFiles
│   ├── cmake_install.cmake
│   ├── codec
│   ├── hal
│   ├── legacy
│   ├── librockchip_mpp.so -> librockchip_mpp.so.1
│   ├── librockchip_mpp.so.0
│   ├── librockchip_mpp.so.1 -> librockchip_mpp.so.0
│   ├── Makefile
│   └── vproc
├── osal
│   ├── CMakeFiles
│   ├── cmake_install.cmake
│   ├── libosal.a
│   ├── Makefile
│   └── test
│       ├── CMakeFiles
│       ├── cmake_install.cmake
│       ├── Makefile
│       ├── mpp_env_test
│       ├── mpp_eventfd_test
│       ├── mpp_log_test
│       ├── mpp_mem_test			  # 测试C库的内存分配器是否正常
│       ├── mpp_platform_test	   # 读取和测试芯片平台信息是否正常
│       ├── mpp_runtime_test		# 测试一些软硬件运行时环境是否正常
│       ├── mpp_thread_test
│       └── mpp_time_test
├── rockchip_mpp.pc
├── rockchip_vpu.pc
├── test
│   ├── CMakeFiles
│   ├── cmake_install.cmake
│   ├── Makefile
│   ├── mpi_dec_mt_test		  # 多线程解码测试
│   ├── mpi_dec_multi_test  # 多实例解码测试
│   ├── mpi_dec_test				# 单线程解码测试
│   ├── mpi_enc_multi_test  # 多实例编码测试
│   ├── mpi_enc_test				# 单线程编码测试
│   ├── mpi_rc2_test
│   ├── mpi_rc_test
│   ├── mpi_test
│   ├── mpp_info_test				# 读取和打印MPP库的版本信息
│   └── vpu_api_test
└── utils
    ├── CMakeFiles
    ├── cmake_install.cmake
    ├── libutils.a
    └── Makefile
```

#### 2.使用测试

```shell
# rk vpu 模块
ls /dev/vpu_service

# rk 解码模块
ls /dev/rkvdec

# rk 编码模块
ls /dev/rkvdec

$ cd mpp/build/linux/aarch64/osal/test
$ sudo ./mpp_platform_test 
mpp[20369]: mpp_plat_test: chip name: rockchip,rk3399-firefly rockchip,rk3399
mpp[20369]: mpp_plat_test: 
mpp[20369]: mpp_plat_test: chip vcodec type 00040202
mpp[20369]: mpp_plat_test: found vpu2 codec
mpp[20369]: mpp_plat_test: found rkvdec decoder
mpp[20369]: mpp_plat_test: found vpu2 encoder
mpp[20369]: mpp_plat_test: 
mpp[20369]: mpp_plat_test: start probing decoder device name:
mpp[20369]: mpp_plat_test: H.264 decoder: /dev/rkvdec
mpp[20369]: mpp_plat_test: H.265 decoder: /dev/rkvdec
mpp[20369]: mpp_plat_test: MJPEG decoder: /dev/vpu_service
mpp[20369]: mpp_plat_test: VP9   decoder: /dev/rkvdec
mpp[20369]: mpp_plat_test: avs   decoder: /dev/vpu_service
mpp[20369]: mpp_plat_test: 
mpp[20369]: mpp_plat_test: start probing encoder device name:
mpp[20369]: mpp_plat_test: H.264 encoder: /dev/vpu_service
mpp[20369]: mpp_plat_test: H.265 encoder: /dev/vpu_service
mpp[20369]: mpp_plat_test: MJPEG encoder: /dev/vpu_service
mpp[20369]: mpp_plat_test: mpp platform test done

$ sudo ./mpp_runtime_test
mpp[20699]: mpp_rt: NOT found ion allocator
mpp[20699]: mpp_rt: found drm allocator
mpp[20699]: mpp_rt_test: mpp found ion buffer is invalid
mpp[20699]: mpp_rt_test: mpp found drm buffer is valid


$ cd mpp/build/linux/aarch64/test
# 通过mpi接口测试解码
$ sudo ./mpi_dec_test -i rtsp://admin:jiangxing123@10.56.0.18:554/h264/ch1/sub/av_stream -o decodetest -w 640 -h 480 -t 7 -n 20

$ sudo ./mpi_dec_test -i test.h264 -o decodefile -w 640 -h 480 -t 7
mpp[15185]: mpi_dec_test: cmd parse result:
mpp[15185]: mpi_dec_test: input  file name: /dev/video0
mpp[15185]: mpi_dec_test: output file name: decodetest
mpp[15185]: mpi_dec_test: config file name: 
mpp[15185]: mpi_dec_test: width      :  640
mpp[15185]: mpi_dec_test: height     :  480
mpp[15185]: mpi_dec_test: type       : 4
mpp[15185]: mpi_dec_test: debug flag : 0
mpp[15185]: mpi_dec_test: max frames : 20
mpp[15185]: mpi_dec_test: mpi_dec_test start
mpp[15185]: mpi_dec_test: input file size -1
mpp[15185]: mpp_info: mpp version: 998f9a2 author: Herman Chen    2020-08-31 [mpp_enc_v2]: Add more log for pts debug
mpp[15185]: mpi_dec_test: 0x39f7360 mpi_dec_test decoder test start w 640 h 480 type 4
mpp[15185]: mpp_rt: NOT found ion allocator
mpp[15185]: mpp_rt: found drm allocator
mpp[15185]: mpi_dec_test: 0x39f7360 get error and check frame_num
mpp[15185]: mpi_dec_test: 0x39f7360 found last packet
mpp[15185]: mpi_dec_test: 0x39f7360 decode get frame 0
mpp[15185]: mpi_dec_test: 0x39f7360 found last packet
mpp[15185]: mpi_dec_test: test success max memory 0.00 MB

$ sudo ./mpi_enc_test -i /dev/video0 -o decodetest -w 640 -h 480 -t 4 -n 20
```

