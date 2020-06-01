[TOC]



# 第十三章 Linux内核裁剪与定制

## Linux 内核源码 

到 www.kernel.org 下载官方内内核。  



### 快速确定主板关联代码 

#### 基础代码 

Linux 移植通常分为体系结构级别移植、处理器级别移植和板级移植 。

- 确定主板名称和默认配置文件。 
  - 如：默认内核配置文件为<arch/arm/configs/ EPC-M28x_defconfig > 
- 确定对应的主板文件。 
  - 如：<arch/arm/mach-omap2/board-am335xevm.c> 
  - <arch/arm/mach-mxs/mach-mx28evk.c> 

#### 驱动代码 

驱动代码在drivers 目录 

#### 其它代码 

文件系统的实现代码、网络子系统的实现代码等。 



## Linux 内核中的 Makefile 文件 

### 顶层 Makefile 

源码目录树顶层 Makefile 是整个内核源码管理的入口，对整个内核的源码编译起着决
定性作用。编译内核时，顶层 Makefile 会按规则递归历遍内核源码的所有子目录下的
Makefile 文件，完成各子目录下内核模块的编译。 

#### 内核版本号 

顶层 Makefile，开头的几行记录了内核源码的版本号 。

```makefile
VERSION = 2
PATCHLEVEL = 6
SUBLEVEL = 35
EXTRAVERSION =3
#说明代码版本为 2.6.35.3
```

内核在目标板运行后，输入 uname -a 命令可以得到印证 。

#### 编译控制 

- 体系结构 

  - Linux 是一个支持众多体系结构的操作系统，在编译过程中需指定体系结构，以与实际平台对应。在顶层 Makefile 中，通过变量 ARCH 来指定 。

  - ```makefile
    ARCH ?= $(SUBARCH)
    #如果进行 ARM 嵌入式 Linux 开发，则必须指定 ARCH 为 arm（注意大小写，须与 arch/目录下的 arm 一致）
    #如：$make ARCH=arm
    ```

- 编译器 

  - 进行 ARM 嵌入式 Linux 开发，必须指定交叉编译器，可以在内核配置通过 CONFIG_CROSS_COMPILE 指定交叉编译器，也可以通过 CROSS_COMPILE 指定。 

  -  ​

    ```shell
    $ make ARCH=arm CROSS_COMPILE= arm-linux-gnueabihf-
    ```

    ```makefile
    CROSS_COMPILE = arm-linux-gnueabihf-
    #注意： CROSS_COMPILE 指定的交叉编译器必须事先安装并正确设置系统环境变量； 如果没有设置环境变量， 则需使用绝对地址
    ```



### 子目录的 Makefile 

几乎每个子目录都有相应的 Makefile 文件，管理着对应目录下的代码。 



Makefile 中有两种表示方式

- 一种是默认选择编译，用 obj-y 表示 

  - ```makefile
    obj-y += usb-host.o # 默认编译 usb-host.c 文件
    obj-y += gpio/ # 默认编译 gpio 目录
    ```

- 另一种表示则与内核配置选项相关联，编译与否以及编译方式取决于内核配置 。

  - ```makefile
    obj-$(CONFIG_WDT) += wdt.o # wdt.c 编译控制
    obj-$(CONFIG_PCI) += pci/ # pci 目录编译控制
    ```

    是否编译 wdt.c 文件，或者以何种方式编译，取决于内核配置后的变量 CONFIG_WDT值：如果在配置中设置为[*]，则静态编译到内核，如果配置为[M]，则编译为 wdt.ko 模块，否则不编译。 



## Linux 内核中的 Kconfig 文件 

内核源码树每个目录下都还包含一个 Kconfig 文件，用于描述所在目录源代码相关的内
核配置菜单，各个目录的 Kconfig 文件构成了一个分布式的内核配置数据库。

通过 make menuconfig（make xconfig 或者 make gconfig）命令配置内核的时候，从 Kconfig 文件读取菜单，配置完毕保存到文件名为.config 的内核配置文件中，供 Makefile 文件在编译内核时使用。 



## 配置和编译 Linux 内核 

### 快速配置内核 

进入 Linux 内核源码数顶层目录，输入 make menuconfig 命令 。

注意： 主机须安装 ncurses 相关库才能正确运行该命令并出现配置界面 。



如果没有在 Makefile 中指定 ARCH，则须在命令行中指定 

```shell
$ make ARCH=arm menuconfig
```



### 内核配置详情 

| 菜单项                                     | 说明                                       |
| --------------------------------------- | ---------------------------------------- |
| General setup --->                      | 内核通用配置选项，包括交叉编译器前缀、本地版本、内核压缩模式、 config.gz 支持、内核 log 缓冲区大小、 initramfs以及更多的内核运行特性支持等 |
| [ ] Enable loadable module support ---> | 内核模块加载支持，通常都需要                           |
| [ ] Enable the block layer --->         | 使能块设备。如果未选中使能，块设备将不能使用， SCSI类字符设备和 USB 大容量类设备也将不能使用。 |
| System Type --->                        | 系统类型，设置 ARM 处理器型号、处理器的特性以及默认的评估板主板       |
| Bus support --->                        | PCMCIA/CardBUS 总线支持，目前已经很少使用             |
| Kernel Features --->                    | 内核特性，包括内核空间分配、实时性配置等特性配置                 |
| Boot options --->                       | 内核启动选项，如果采用内置启动参数，则在这里设置                 |
| CPU Power Management --->               | CPU 电源管理，包括处理器频率降频、休眠模式支持等               |
| Floating point emulation --->           | 浮点模拟                                     |
| Userspace binary formats --->           | 用户空间二进制支持                                |
| Power management options --->           | 电源管理选项                                   |
| [ ] Networking support --->             | 网络协议支持，包括网络选项、 CAN-Bus、红外、无线、 NFC等。其中的网络选项还有更多配置项，如 IPv4、 IPv6 等 |
| Device Drivers --->                     | 设备驱动，包含多级下级菜单，包括驱动通用选项、 MTD设备、字符设备、网络设备、输入设备、 I2C 总线、 SPI 总线、 USB 总线、 GPIO、声卡、显卡等各种外设配置菜单 |
| File systems --->                       | 文件系统， 包含 Ext2、 Ext3、 Ext4、 JFFS、 NFS、 DOS 等各种文件系统， 以及本地语言支持等 |
| Kernel hacking --->                     | 内核 Hacking，在内核调试阶段可酌情使能其中的选项，以获得需要的调试信息  |
| Security options --->                   | 安全选项                                     |
| < > Cryptographic API --->              | 加密接口，内核提供的一些加密算法如 CRC32、MD5、SHA1、SHA224 等 |
| OCF Configuration --->                  | 开放的加密框架                                  |
| Library routines --->                   | 库例程                                      |
| Load an Alternate Configuration File    | 装载一个配置文件                                 |
| ave an Alternate Configuration File     | 保存为一个配置文件                                |

#### 通用设置  General setup  

| 选项                                       | 说明                                       |
| ---------------------------------------- | ---------------------------------------- |
| ( ) Cross-compiler tool prefix           | 交叉编译器前缀，将会设置 CONFIG_CROSS_COMPILE 变量， 等同于 make CROSS_COMPILE=prefix- |
| ( ) Local version - append to kernel release | 填写本地版本                                   |
| [ ] Automatically append version informationto the version string | 自动增加版本信息。如果用了 Git 管理内核源码，每次 Git提交都会造成内核版本号增加。谨慎使用该选项 |
| < > Kernel .config support               | 选中该选项会将当前内核配置信息保存到内核中                    |
| [ ] Enable access to .config through/proc/config.gz | 通过/proc/config.gz 获得当前运行内核的配置信息。建议选中     |
| [ ] Initial RAM filesystem and RAM disk(initramfs/initrd) support | Initramfs 支持，使能该特性可以将一个文件系统打包到内核文件中，内核启动不需要额外的文件系统 |
| ( ) Initramfs source file(s)             | Initramfs 文件系统的路径，通常放在源码树 usr 目录下        |

#### 内核特性  Kernel Features  

| 选项                                       | 说明                                       |
| ---------------------------------------- | ---------------------------------------- |
| [ ] Tickless System (Dynamic Ticks)      | 无时钟系统支持，根据系统运行状况来启用或者禁用时钟，能让内核运行更有效且更省电。 A8 这样的处理器建议选中 |
| [ ] High Resolution Timer Support        | 高精度定时器。处理器支持则可选中                         |
| Memory split (3G/1G user/kernel split)---> | 4G 内存分割比例，内核和用户空间： 3G/1G、 2G/2G、 1G/2G。早期内核是 3G/1G 固定分割，目前可配置 |
| Preemption Model (No Forced Preemption(Server)) ---> | 内核抢占模式，可选值：No Forced Preemption (Server)Voluntary Kernel Preemption (Desktop)Preemptible Kernel (Low-Latency Desktop)需要实时性则须设置为 Preemptible Kernel |
| [ ] Compile the kernel in Thumb-2 mode(EXPERIMENTAL) | 以 Thumb-2 指令集编译内核。不推荐                    |
| [ ] High Memory Support                  | 高端内存，嵌入式系统通常不用选                          |

#### 启动选项 

默认启动参数通过“Default kernel command string”设置 

```c
(root=/dev/mmcblk0p2 rootwait console=ttyO0,115200) Default kernel command string
```

内核参数类型通过 Kernel command line type 来设置 

- ( ) Use bootloader kernel arguments if available
  - 可接受bootloader传递的参数启动
- ( ) Extend bootloader kernel arguments
- ( ) Always use the default kernel command string 
  - 只能使用默认内核启动参数 

#### 网络支持 

网络支持部分，包括了以太网、 CAN、红外、蓝牙、无线等各种网络的支持配置选项。 

从 Networking support -> Networking options， 可进入网络选项配置界面 。

| 选项                                       | 说明                                       |
| ---------------------------------------- | ---------------------------------------- |
| < > Packet socket                        | 选中支持应用直接与网卡通信而不需要在内核中实现网络协议，建议选中         |
| < > Unix domain sockets                  | UNIX domain Socket 支持，建议选中。如果采用 udev/mdev动态管理设备，则必须选中 |
| < > PF_KEY sockets                       | PF_KEY 协议族，内核安全相关，建议选中                   |
| [ ] TCP/IP networking                    | TCP/IP 支持，使用网络通常需选中，还有更多的下级菜单，如 IPv4、 IPv6 等设置 |
| [ ] Network packet filtering framework(Netfilter) ---> | 对网络数据包进行过滤，如果需要防火墙功能，则必须选中。有下级菜单，根据实际需要配置 |
| < > 802.1d Ethernet Bridging             | 802.1d 以太网桥                              |
| < > 802.1Q VLAN Support                  | 802.1Q 虚拟局域网                             |
| [ ] QoS and/or fair queueing --->        | Qos 支持，该选项可支持多种不同的包调度算法，否则仅能使用简单的 FIFO 算法 |

使用 Linux 的系统都会用到网络，而使用网络又往往离不开 TCP/TP，故建议在配置中选中 TCP/IP 选项，并选中下级全部选项 。

#### 设备驱动 

| 选项                                       | 说明                                       |
| ---------------------------------------- | ---------------------------------------- |
| Generic Driver Options --->              | 通用设备驱动选项                                 |
| CBUS support --->                        | CBUS 支持，不清楚则不要选                          |
| < > Connector - unified userspace <-> kernelspacelinker ---> | 统一的用户空间<-->内核空间连接器，工作在 Netlinksocket 协议顶层，不确定则不选 |
| < > Memory Technology Device (MTD) support---> | 内存技术设备，如 FLASH、 RAM 等支持。通常需要选中           |
| Device Tree and Open Firmware support ---> | /proc 设备树支持，可选中                          |
| < > Parallel port support --->           | 并口支持，嵌入式系统通常不选                           |
| [ ] Block devices --->                   | 块设备，选中，否则不能操作任何块设备                       |
| [ ] Misc devices --->                    | 杂项设备。通常选中，如需用 eeprom 设备，则必选              |
| SCSI device support --->                 | SCSI 设备支持。如要用 U 盘，则必选                    |
| < > Serial ATA and Parallel ATA drivers ---> | SATA 和 PATA 设备支持。除非硬件支持，否则不选             |
| [ ] Multiple devices driver support (RAID and LVM)---> | 多设备支持(RAID&LVM)，嵌入式通常不选                  |
| < > Generic Target Core Mod (TCM) and ConfigFSInfrastructure ---> | TCM 存储引擎和 ConfigFS 控制                    |
| [ ] Network device support --->          | 网络设备支持，包括网卡、 PHY 驱动、 ppp 协议等选择           |
| [ ] ISDN support --->                    | ISDN 支持                                  |
| < > Telephony support --->               | 电话支持。在 Linux 下使用 Modem 拨号，无需使能该选项        |
| Input device support --->                | 输入设备支持，包括键盘、鼠标、触摸屏、游戏杆等                  |
| Character devices --->                   | 字符设备，包括 tty 等设备。特别注意，串口驱动配置也在这里面         |
| < > I2C support --->                     | I2C 支持。 I2C 协议和控制器配置                     |
| [ ] SPI support --->                     | SPI 支持。 SPI 协议和 SPI 控制器                  |
| PPS support --->                         | PPS 支持                                   |
| PTP clock support --->                   | PTP 时钟支持                                 |
| [ ] GPIO Support --->                    | GPIO 支持                                  |
| < > PWM Support --->                     | PWM 支持                                   |
| < > Dallas's 1-wire support --->         | Dallas 单总线支持                             |
| < > Power supply class support --->      | 电源管理类支持                                  |
| < > Hardware Monitoring support --->     | 硬件监测支持，各种传感器                             |
| < > Generic Thermal sysfs driver --->    | Thermal sysfs 接口支持                       |
| [ ] Watchdog Timer Support --->          | 看门狗支持，包括硬件看门狗和软件看门狗                      |
| Sonics Silicon Backplane --->            | SSB 总线支持                                 |
| Broadcom specific AMBA --->              | 博通 AMBA 总线支持                             |
| Multifunction device drivers --->        | 多功能设备驱动支持                                |
| [ ] Voltage and Current Regulator Support ---> | 电压和电流调节支持。如果有电源管理芯片，通常需要选中               |
| < > Multimedia support --->              | 多媒体支持。 V4L2 在这里面配置                       |
| Graphics support --->                    | 图形支持。 Framebuffer、背光、 LCD、开机 LOGO 等配置    |
| < > Sound card support --->              | 声卡支持                                     |
| [ ] HID Devices --->                     | HID 设备，使用 USB 鼠标键盘等 HID 设备必须选中该选项        |
| [ ] USB support --->                     | USB 支持                                   |
| < > MMC/SD/SDIO card support --->        | SD/MMC 设备支持                              |
| < > Sony MemoryStick card support(EXPERIMENTAL) ---> | Sony 记忆棒支持                               |
| [ ] LED Support --->                     | LED 子系统和驱动                               |
| [ ] Accessibility support --->           | 易用性支持，嵌入式通常不选                            |
| [*] Real Time Clock --->                 | 实时时钟，包括处理器内部时钟和外扩时钟选择                    |
| [ ] DMA Engine support --->              | 引擎支持                                     |
| [ ] Auxiliary Display support --->       | 辅助显示支持                                   |
| < > Userspace I/O drivers --->           | 用户空间 I/O 驱动（uio 支持）                      |
| Virtio drivers --->                      | Virtio 驱动                                |
| [*] Staging drivers --->                 | 分阶段驱动                                    |
| Hardware Spinlock drivers --->           | 硬件 Spinlock 驱动                           |
| [ ] IOMMU Hardware Support --->          | IOMMU 硬件支持，根据具体硬件选择                      |
| [ ] Virtualization drivers --->          | 虚拟化驱动                                    |
| [ ] Generic Dynamic Voltage and Frequency Scaling(DVFS) support ---> | 通用的动态电压和频率调节                             |

#### 文件系统  File systems 

| 选项                                       | 说明                                       |
| ---------------------------------------- | ---------------------------------------- |
| < > Second extended fs support           | Ext2 文件系统支持，建议选中或模块编译                    |
| < > Ext3 journalling file system support | Ext3 文件系统支持，建议选中或模块编译                    |
| < > The Extended 4 (ext4) filesystem     | Ext4 文件系统支持，建议选中或模块编译                    |
| < > Reiserfs support                     | Reiserfs 是一种先进的文件系统，不过嵌入式中不常用            |
| < > JFS filesystem support               | IBM 开发的日志文件系统，嵌入式中不常用                    |
| < > XFS filesystem support               | XFS 文件系统支持                               |
| < > GFS2 file system support             | GFS2 文件系统支持                              |
| < > Btrfs filesystem (EXPERIMENTAL)Unstable disk format | BtrFS 文件系统支持。 BtrFS 是一种新型文件系统，被称为下一代 Linux 文件系统 |
| < > NILFS2 file system support(EXPERIMENTAL) | NiLFS2 文件系统支持                            |
| [ ] Dnotify support                      | 文件系统通知系统，建议选中                            |
| [ ] Inotify support for userspace        | 用户空间 Inotify 支持，建议选中                     |
| [ ] Filesystem wide access notification  | Fanotify 支持，能比 Inotify 传递更多信息            |
| [ ] Quota support                        | 磁盘配额支持。选中后可限制某个用户或者某组用户的磁盘占用空间。嵌入式中不常用   |
| < > Kernel automounter version 4support (also supports v3) | 第 4 版内核自动加载远程文件系统支持（同时支持第 3 版）           |
| < > FUSE (Filesystem in Userspace) support | 选中后则允许在用户空间实现一个文件系统                      |
| Caches --->                              | 文件系统 Cache 支持                            |
| CD-ROM/DVD Filesystems --->              | CD-ROM 和 DVD 支持，有 ISO 9660 和 UDF 两个选项。如果需要支持 CD/DVD，则可选 |
| DOS/FAT/NT Filesystems --->              | DOS/FAT/NTFS 文件系统支持。如果需要支持 U 盘，必须选中 MDOS 和 VFAT 支持 |
| Pseudo filesystems --->                  | 伪文件系统，基于内存的文件系统，如 tmpfs                  |
| [ ] Miscellaneous filesystems --->       | 其它杂项文件系统，很多文件系统都归类在这里，嵌入式中常用的 cramfs、 ubifs 等都在这里配置 |
| [ ] Network File Systems --->            | 网络文件系统。建议选中，通过 NFS 能方便调试，对于嵌入 式系统， NFS Server 通常不选 |
| Partition Types --->                     | 分区支持                                     |
| < > Native language support --->         | 本地语言支持，通常选中 iso-8859-1、 CP437、 CP437 和 utf-8等 |



### 编译内核 

#### 从内核码源编译成zImage

内核配置完成，输入 make 命令即可开始编译内核。如果没有修改 Makefile 文件并指定
ARCH 和 CROSS_COMPILE 参数，则须在命令行中指定 。

```shell
$ make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi-
```

目前大多数主机都是多核处理器，为了加快编译进度，可以开启多线程编译，在 make
的时候加上“-jN”即可， N 的值为处理器核心数目的 2 倍。 

```shell
$ make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- -j8
```

如果编译不出错，编译完成，会生成 vmlinux、 Image、 zImage 等文件 

| 文件                               | 说明                                       | 备注    |
| -------------------------------- | ---------------------------------------- | ----- |
| vmlinux                          | 未经压缩、带调试信息和符号表的内核文件， elf 格式              | 顶层目录下 |
| arch/arm/boot/compressed/vmlinux | 经过压缩的 Image，并加入了解压头的 elf 格式文件            |       |
| arch/arm/boot/Image              | 将 vmlinux 去除调试信息、注释和符号表等，只包含内核代码和数据后得到的非 elf 格式文件 |       |
| arch/arm/boot/zImage             | 经过 objcopy 处理，能直接下载到内存中执行的内核映像文件         |       |

- zImage

zImage 是通常情况下默认的压缩内核，可以直接加载到内存地址并开始执行。 

- uImage 

对于 ARM Linux 系统，大多数采用 U-Boot 引导，很少直接使用 zImage 映像，实际上
更多的是 uImage。  

uImage 是 U-Boot 默认采用的内核映像文件，它是在 zImage 内核映像之
前加上了一个长度为 64 字节信息头的映像。这 64 字节信息头包括映像文件的类型、加载位置、生成时间、大小等信息 。



在 U-Boot 下，通过 bootm 命令可以引导 uImage 映像文件启动。 

```
$ tftp C0008000 uImage
$ bootm C0008000
```



#### 把zImage转为uImage

- mkimage 工具 

从 zImage 生成 uImage 需要用到 mkimage 工具。该工具可在编译 U-Boot 源码后从 tools目录下获得，复制到系统/usr/bin 目录即可 。

对于 Ubuntu 系统，还可用 sudo apt-get installu-boot-tools 命令安装得到。 



进入 mkimage 文件所在目录执行该文件，或者在安装 mkimage工具后，使用 mkimage 工具根据 zImage 制作 uImage 映像文件的命令如下： 

```shell
$ mkimage [-x] -A arch -O os -T type -C comp -a addr -e ep -n name -d data_file[:data_file...] image
#命令参数中需要指定体系结构、操作系统类型、压缩方式和入口地址等信息
```

| 参数           | 说明                                       |
| ------------ | ---------------------------------------- |
| -A arch      | 指定处理器的体系结构为 arch，可能值有： alpha、 arm、 x86、 ia64、 mips、 mips64、 ppc、s390、 sh、 sparc、 sparc64、 m68k 等 |
| -O os        | 指定操作系统类型为 os，可用值有： openbsd、 netbsd、 freebsd、 4_4bsd、 linux、 svr4、 esix、solaris、 irix、 sco、 dell、 ncr、 lynxos、 vxworks、 psos、 qnx、 u-boot、 rtems、 artos 等 |
| -T type      | 指定映象类型为 type，可能值有： standalone、 kernel、 ramdisk、 multi、 firmware、 script、filesystem 等 |
| -C comp      | 指定映象压缩方式为 comp，可能值有：none 不压缩（推荐， zImage 已经过 bzip2 压缩，通常无需再压缩）gzip 用 gzip 的压缩方式bzip2 用 bzip2 的压缩方式 |
| -a addr      | 指定映象在内存中的加载地址为 addr（16 进制）。制作好的映象下载到内存时， 须按照该参数所指定的地址值来下载。 U-Boot 的 bootm xxx 命令会判断 xxx 是否与 addr 相同：(1)如果不同，则从 xxx 这个地址开始提取出这个 64 字节的头部，对其进行分析，然后把去掉头部的内核复制到 addr 地址中去运行。(2)如果相同，则不作处理， 仅将-e 指定的入口地址推后 64 字节， 即跳过这 64 字节的头部信息。 |
| -e ep        | 指定映象运行的入口地址为 ep（16 进制）。 ep 的值为 addr+0x40，也可设置为和 addr 相同 |
| -n name      | 指定映象文件名为 name                            |
| -d data_file | 指定制作映象的源文件，通常是 zImage                    |
| image        | 输出的 uImage 映像文件名称，通常设置为 uImage           |

对于 EPC-28x 处理器，内存起始地址为 0x40000000，从 zImage 生成 uImage 映像文件
的命令实际操作范例： 

```shell
$ mkimage -A arm -O linux -T kernel -C none -a 0x40008000 -e 0x40008000 -n 'Linux-2.6.35' -d arch/arm/boot/zImage arch/arm/boot/uImage
```

内存地址与处理器相关，在不同处理器上可能有差异 .



查看一个 uImage 映像文件的文件头信息 

```shell
$ mkimage -l uImage
Image Name: Linux-2.6.35.3-571-gcca29a0-g191
Created: Tue Nov 17 11:57:47 2015
Image Type: ARM Linux Kernel Image (uncompressed)
Data Size: 2572336 Bytes = 2512.05 kB = 2.45 MB
Load Address: 40008000
Entry Point: 40008000
```

#### 从内核源码直接生成 uImage

在<arch/arm/boot/Makefile>文件中给出了 uImage 的生成规则： 

```makefile
quiet_cmd_uimage = UIMAGE $@
	cmd_uimage = $(CONFIG_SHELL) $(MKIMAGE) -A arm -O linux -T kernel \
				-C none -a $(LOADADDR) -e $(STARTADDR) \
				-n 'Linux-$(KERNELRELEASE)' -d $< $@
```

生成 uImage 的编译命令为 make uImage 

```shell
$ make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- -j8 uImage
```



#### 编译内核模块 

如果内核中有配置为<M>的模块或者驱动，需要在编译内核后再通过 make modules 命
令编译这些模块或者驱动 

```shell
$ make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- modules
```

编译得到的内核模块文件以“.ko”结尾，这些可以通过 insmod 命令插入到运行的内核中。 

```shell
# insmod kernel/drivers/net/bonding/bonding.ko
```



有的模块则可能编译后得到多个“.ko”文件，或者依赖于其它模块文件，且各文件插入还有顺序要求， 需要通过 make modules_install 命令安装模块 ，可将编译得到的全部模块安装到某一目录下，并且还会生成模块的依赖关系文件。 

```shell
$ make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- INSTALL_MOD_PATH=/home/chenxibing/work/rootfs modules_install
```



安装后将在安装目录下生成“lib/modules/内核版本/”目录，将“lib/modules/内核版本/”复制到目标系统后根目录后，就可以用 modprobe 命令进行模块安装 

```shell
#模块依赖关系
kernel/drivers/net/bonding/bonding.ko: 
kernel/drivers/usb/serial/usbserial.ko: 
kernel/drivers/usb/serial/ftdi_sio.ko:kernel/drivers/usb/serial/usbserial.ko 
```

```shell
# modprobe ftdi_sio
```



### 运行内核 

得到 uImage 映像文件后，将 uImage 加载到内存地址 ep-0x40 处（0x40007fc0），通过 bootm 命令即可运行内核： 

```shell
# tftp 40007fc0 uImage
# bootm 40007fc0
```





# 第十四章 Linux 设备驱动开发基础 



## Linux 内核模块 

在 32 位系统上， Linux 内核将 4G 空间分为 0~3G 的用户空间和 3~4G 的内核空间。
用户程序运行在用户空间，可通过中断或者系统调用进入内核空间； Linux 内核以及内核模块则只能在内核空间运行。 

Linux 内核具有很强的可裁剪性，很多功能或者外设驱动都可以编译成模块，在系统运
行中动态插入或者卸载，在此过程中无需重启系统。 



### 编写内核模块 

#### 头文件 

内核模块头文件<linux/module.h>和<linux/init.h>是必不可少的 ，不同模块根据功能的差异，所需要的头文件也不相同 。

```C
#include <linux/module.h>
#include <linux/init.h>
```

#### 模块初始化 

模块的初始化负责注册模块本身 ，只有已注册模块的各种方法才能够被应用程序使用并发挥各方法的实际功能。 

模块并不是内核内部的代码，而是独立于内核之外[注]，通过初始化，能够让内核之
外的代码来替内核完成本应该由内核完成的功能，模块初始化的功能相当于模块与内核之间衔接的桥梁，告知内核“我进来了，我已经做好准备为您服务了”。 

内核模块初始化函数

```c
//模块初始化函数一般都需声明为 static
//__init 表示初始化函数仅仅在初始化期间使用，一旦初始化完毕，将释放初始化函数所占用的内存
static int __init module_init_func(void)
{
	初始化代码
}
module_init(module_init_func);
//module_init宏定义会在模块的目标代码中增加一个特殊的代码段，用于说明该初始化函数所在的位置。
```

当使用 insmod 将模块加载进内核的时候，初始化函数的代码将会被执行。 

#### 模块退出 

模块的退出相当于告知内核“我要离开了，将不再为您服务了”。 

内核模块退出函数

```c
//模块退出函数没有返回值；
//__exit 标记这段代码仅用于模块卸载；
static void __exit module_exit_func(void)
{
	模块退出代码
}
module_exit(module_exit_func);
//没有 module_exit 定义的模块无法被卸载
```

当使用 rmmod 卸载模块时，退出函数的代码将被执行。 

#### 许可证 

Linux 内核是开源的，遵守 GPL 协议，所以要求加载进内核的模块也最好遵循相关协议。 

为模块指定遵守的协议用 MODULE_LINCENSE 来声明 :

```c
MODULE_LICENSE("GPL");
```

内核能够识别的协议有“GPL”、“GPL v2”、“GPL and additional rights（GPL 及附加权
利）”、“Dual BSD/GPL（BSD/GPL 双重许可）”、“Dual MPL/GPL（MPL/GPL 双重许可）”以及“Proprietary（私有）”。 

#### 符号导出 

如果希望一个模块的符号能被其它模块使用，则必须显式的用 EXPORT_SYMBOL 将符号导出 .

```c
EXPORT_SYMBOL(module_symbol);
```

#### 模块描述 

模块编写者还可以为所编写的模块增加一些其它描述信息，如模块作者、模块本身的描述或者模块版本等 

```c
MODULE_AUTHOR("Abing <Linux@zlgmcu.com>");
MODULE_DESCRIPTION("ZHIYUAN ecm1352 beep Driver");
MODULE_VERSION("V1.00");
```

模块描述以及许可证声明一般放在文件末尾。 

#### 内核模块示例 hello.c

```c
#include <linux/module.h>
#include <linux/init.h>
static int __init hello_init(void)
{
  printk("Hello, I'm ready!\n");	//printk 函数是由内核定义并导出给模块使用的一个 printf 的内核版本，用法基本与 printf函数相同，不过 printk 不支持浮点数。
  return 0;
}
static void __exit hello_exit(void)
{
  printk("I'll be leaving, bye!\n");
}
module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL")；
```



### 编译内核模块

编译模块需要内核代码，并配置和编译内核代码 。编译模块的内核配置必须与所运行内核的编译配置一样 。

Linux 2.6 在内核树之外编译内核模块的典型 Makefile 文件。 

```makefile
# Makefile2.6
ifneq ($(KERNELRELEASE),)
#kbuild syntax. dependency relationshsip of files and target modules are listed here.
obj-m := beepdrv.o
else
PWD := $(shell pwd)
KVER = 2.6.27.8
KDIR := /home/chenxibing/lpc3250/linux-2.6.27.8
all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules
clean:
	rm -rf .*.cmd *.o *.mod.c *.ko .tmp_versions
endif
```



### 加载和卸载 

加载模块使用 insmod 命令，卸载模块使用 rmmod 命令。 

```shell
$ insmod hello.ko
$ rmmod hello.ko
#加载和卸载模块必须具有 root 权限 。
```

对于可接受参数的模块，在加载模块的时候为变量赋值即可，卸载模块无需参数。 

```shell
$ insmod hello.ko num=8
$ rmmod hello.ko
```



### 带参数的内核模块 

模块参数必须使用 module_param 宏来声明，通常放在文件头部。

module_param 需要 3个参数：变量名称、类型以及用于 sysfs 入口的访问掩码。 

```c
static int num = 5;
module_param(num, int, S_IRUGO);
```

- 内核模块支持的参数类型有： bool、 invbool、 charp、 int、 short、 long、 uint、 ushort和 ulong。 
- 访问掩码的值在<linux/stat.h>定义， S_IRUGO 表示任何人都可以读取该参数，但不能修改。 
- 支持传参的模块需包含 moduleparam.h 头文件。 



能够接受参数的模块范例 

```c
#include <linux/module.h>
#include <linux/init.h>
// moduleparam.h 文件已经包含在 module.h 文件中

static int num = 3;
static char *whom = "master";

module_param(num, int, S_IRUGO);
module_param(whom, charp, S_IRUGO);

static int __init hello_init(void)
{
  printk(KERN_INFO "%s, I get %d\n", whom, num); //KERN_INFO 表示这条打印信息的级别
  return 0;
}

static void __exit hello_exit(void)
{
  printk("I'll be leaving, bye!\n");
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL");
```



printk打印级别

```c
#define KERN_EMERG "<0>" /* system is unusable */
#define KERN_ALERT "<1>" /* action must be taken immediately */
#define KERN_CRIT "<2>" /* critical conditions */
#define KERN_ERR "<3>" /* error conditions */
#define KERN_WARNING "<4>" /* warning conditions */
#define KERN_NOTICE "<5>" /* normal but significant condition */
#define KERN_INFO "<6>" /* informational */
#define KERN_DEBUG "<7>" /* debug-level messages */
```

0最高，7最低



## Linux 设备 

Linux 系统中的设备可以分为字符设备、块设备和网络设备这 3 类。 

- 字符设备
  - 字符设备是能够像字节流一样被访问的设备，当对字符设备发出读写请求，
    相应的 I/O 操作立即发生。 
  - 如 终端、串口、键盘、鼠标等
- 块设备 
  - 块设备是 Linux 系统中进行 I/O 操作时必须以块为单位进行访问的设备，块设
    备能够安装文件系统。块设备驱动会利用一块系统内存作为缓冲区，因此对块设备发出读写访问，并不一定立即产生硬件 I/O 操作。
  - 如硬盘、软驱等等。 
- 网络设备 
  - 网络设备既可以是网卡这样的硬件设备，也可以是一个纯软件设备如回环设
    备。网络设备由 Linux 的网络子系统驱动，负责数据包的发送和接收，而不是面向流设备。
  - 在 Linux系统文件系统中网络设备没有节点。对网络设备的访问是通过 socket调用产生，而不是普通的文件操作如 open/close 和 read/write 等。 



### 设备节点 

设备（包括硬件设备）在 Linux 系统下，表现为设备节点，也称设备文件。 

它们存储在文件系统中（通常在/dev 目录下），仅仅记录了其所属的设备类别、主设备号和从设备号等设备相关信息 。

```shell
~$ ls -l /dev/ttyS0 /dev/sda1
brw-rw---- 1 root disk 8, 1 2011-01-07 17:48 /dev/sda1
crw-rw---- 1 root dialout 4, 64 2011-01-07 17:48 /dev/ttyS0
#8是主设备号，1是子设备号
#4是主设备号，64是子设备号
```

### 设备编号 

设备编号由主设备号和从设备号构成。在 Linux 内核中，使用 dev_t 类型来保存设备编号。 dev_t 是一个 32 位数，高 12 位是主设备号，低 20 位是次设备号。 

主设备号确定设备类型，从设备号确定设备文件所指定的具体设备。



231-239是用户可以使用的主设备号吗，其他都是系统占用的主设备号。

```shell
# cat /proc/devices
Character devices:
1 mem
4 /dev/vc/0
4 tty
4 ttyS
5 /dev/tty
5 /dev/console
7 vcs
10 misc
13 input
14 sound
29 fb
90 mtd
116 alsa
180 usb
189 usb_device
252 usbmon
253 ubi0
254 rtc

Block devices:
259 blkext
7 loop
8 sd
31 mtdblock
65 sd
66 sd
67 sd
68 sd
69 sd
70 sd
71 sd
128 sd
129 sd
130 sd
131 sd
132 sd
133 sd
134 sd
135 sd
```

未来版本设备号结构和表述方式发生变化 ，不应当对设备号的位数和表述结构做任何假设。 



程序中查询一个设备的主次设备号

```c
MAJOR(dev_t dev);
MINOR(dev_t dev);
```

已知一个设备的主次设备号，要转换成 dev_t 类型的设备编号

```c
dev_t MKDEV(int major, int minor);
```



### 申请和释放设备编号 

在建立一个设备节点之前，驱动程序首先应当为这个设备获得一个可用的设备号，注销
设备需要释放所占用的设备号。 

- 静态获取主设备号 

```c
int register_chrdev_region(dev_t first,unsigned int count,char *name);
//这个函数可以向系统注册 1 个或者多个主设备号， first 是起始编号， count 是主设备号的数量， name 则是设备名称。注册成功返回 0，否则返回错误码。
```

- 动态获取主设备号 

一个驱动可能在多个系统上运行，为了避免出现设备号冲突，必须采用动态设备号 。

```c
alloc_chrdev_region(dev_t *dev, unsigned int firstminor, unsigned int count, char *name);
//dev 用于保存已经获得的编号范围的第一个值， 
//firstminor 是第一个次设备号，通常是 0， 
//count 是获得的编号数量， 
//name 是设备名称。
```

```c
ret = alloc_chrdev_region(&devno, minor, 1, "char_cdev"); /* 从系统获取主设备号 */
major = MAJOR(devno); /* 保存获得的主设备号 */
if (ret < 0) {
  printk(KERN_ERR "cannot get major %d \n", major);
  return -1;
}
```

- 释放设备号 

```c
void unregister_chrdev_region(dev_t from, unsigned count);
```



### 设备的注册和注销 

linux 2.6 内核用 cdev 数据结构来描述字符设备 

```c
struct cdev {
  struct kobject kobj; //2.6 内核设备模型的基本结构
  struct module *owner; //所属对象， 一般设置为 THIS_MODULE；
  const struct file_operations *ops;//与设备相关联的操作方法；
  struct list_head list;
  dev_t dev; //2.6 内核中设备的设备号。
  unsigned int count;
};
```



使用 cdev 步骤 

- 分配 cdev 结构 

在注册设备之前，必须分配并注册一个或者多个 cdev 结构 

```c
struct cdev *char_cdev = cdev_alloc(); /* 分配 char_cdev 结构 */
```

- 初始化 cdev 结构 

```c
void cdev_init(struct cdev *cdev, const struct file_operations *fops)
//参数 fops 用于指定设备的操作方法
  
cdev_init(char_cdev, &char_cdev_fops); /* 初始化 char_cdev 结构 */
```

```c
struct file_operations char_old_fops = {
  .owner = THIS_MODULE,
  .read = char_old_read,
  .write = char_old_write,
  .open = char_old_open,
  .release = char_old_release,
  .ioctl = char_old_ioctl
}
```

- 往系统添加一个 cdev 

```c
char_cdev->owner = THIS_MODULE;
if (cdev_add(char_cdev, devno, 1) != 0) { /* 增加 char_cdev 到系统中 */
  printk(KERN_ERR "add cdev error!\n");
  goto error1;
}
```

- 删除 cdev 

```c
cdev_del(char_cdev); /* 移除字符设备 */
```



## Linux 设备驱动 

驱动是 Linux 系统中设备和用户之间的桥梁， Linux 系统中，访问设备必须通过设备驱动进行操作，用户程序是不能直接操作设备的。 

![](https://note.youdao.com/yws/public/resource/ea43181f60c17fcc4449163ab62b9e2c/xmlnote/WEBRESOURCE728fa62e8ad977afd18e3c4c88c35383/9520)

### 驱动的基本要素 

Linux 设备驱动是具有入口和出口的一组方法的集合，各方法之间相互独立。  

驱动内部逻辑结构 

![](https://note.youdao.com/yws/public/resource/ea43181f60c17fcc4449163ab62b9e2c/xmlnote/WEBRESOURCE12df35d652a129f03b6412768932cc8d/9522)

Linux 设备在内核中是用设备号进行区分的，而决定这些设备号的正是设备驱动程序。 

一个完整的设备驱动必须具备以下基本要素： 

- 驱动的入口和出口 
  - 只与内核模块管理子系统有交互。 在加载内核的时候执行入口代码，卸载的时候执行出口代码。 
- 操作设备的各种方法 
  - 只有经过相应的系统调用，各方法才能发挥相应的功能 
  - 如应用程序执行 read()系统调用，内核才能执行驱动 xxx_read()方法的代码。 
- 提供设备管理方法支持 
  - 包括设备号的分配和设备的注册等。这部分代码与内核版本以及最终所采用的设备管理方法相关。

#### 驱动和应用程序的差别 

- 在程序组成和逻辑方面 
  - 普通应用程序一般都是由始至终完成某个任务，而驱动程
    序内部各方法之间相互独立，没有逻辑联系 。
- 在系统资源访问方面 
  - 内核模块运行在内核态，可以操作系统的任何资源，包括硬
    件，但是应用程序却不能直接访问系统硬件，只有借助驱动程序才能访问硬件。 
- 在出错危害性方面 
  - 应用程序出错或者崩溃一般不会引起内核崩溃，可以通过杀死
    程序进程终止，但是内核模块出错，有可能导致内核崩溃，一旦内核崩溃，只能复
    位系统。 

#### 驱动程序基本示例 内核模块+申请设备号

只有入口和出口的驱动程序代码 

```c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>

#define DEVICE_NAME "char_null"	//设备名称为char_null
static int major = 232; /* 保存主设备号的全局变量 */ //设置为0是动态获取，否则是静态获取

static int __init char_null_init(void)	//初始化内核模块函数
{
  int ret;

  ret = register_chrdev(major, DEVICE_NAME, &major); /* 申请设备号和注册 */
  if (major > 0) { /* 静态设备号 */
    if (ret < 0) {
      printk(KERN_INFO " Can't get major number!\n");
      return ret;
    }
  } else { /* 动态设备号 */
    printk(KERN_INFO " ret is %d\n", ret);
    major = ret; /* 保存动态获取到的主设备号 */
  }
  printk(KERN_INFO "%s ok!\n", __func__);
  return ret;
}

static void __exit char_null_exit(void)	//退出内核模块函数
{
  unregister_chrdev(major, DEVICE_NAME);
  printk(KERN_INFO "%s\n", __func__);
}

module_init(char_null_init);
module_exit(char_null_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Chenxibing, linux@zlgmcu.com");
```

将这个驱动编译得到 char_null.ko 模块，可以插入内核，也可从内核中卸载。插入内核
后，可以查看/proc/devices 文件，看设备号的分配情况。 



### udev 动态设备管理

Linux 2.6 引入了动态设备管理， 用 udev 作为设备管理器 。

udev 根据 sysfs 系统提供的设备信息实现对/dev 目录下设备节点的动态管理，包括设备节点的创建、删除等。 

sysfs 是 2.6 内核引入的用于管理设备的一种虚拟文件系统，挂载在/sys 目录下。

  

引入udev 作为动态设备管理器步骤

- 调用 class_create()为设备创建一个 class 类

```c
#define class_create(owner, name) \
({ \
  static struct lock_class_key __key; \
  __class_create(owner, name, &__key); \
)
extern struct class * __must_check __class_create ( struct module *owner,
                                                   const char *name,
                                                   struct lock_class_key *key);

class_create(THIS_MODULE, "char_cdev_class");
```

- 销毁类

```c
void class_destroy(struct class *cls);
```

- 调用 device_create()为每个设备创建对应的设备。 

```c
extern struct device *device_create (struct class *cls, struct device *parent,
                                     dev_t devt, void *drvdata,
                                     const char *fmt, ...);

device_create(char_cdev_class, NULL, devno, NULL, "char_cdev" "%d", MINOR(devno));
```

- 销毁在 sysfs 中创建的设备节点相关文件 

```c
void device_destroy(struct class *cls, dev_t devt);
```



#### 支持 udev 的驱动范例 

实现了驱动的入口和出口，设备的注册注销 .

```c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/device.h>

static int major = 232; /* 静态设备号方式的默认值 */
static int minor = 0; /* 静态设备号方式的默认值 */
module_param(major, int, S_IRUGO);	//带模块参数
module_param(minor, int, S_IRUGO);

struct cdev *char_null_udev; /* cdev 数据结构 */
static dev_t devno; /* 设备编号 */
static struct class *char_null_udev_class;

#define DEVICE_NAME "char_null_udev"

static int __init char_null_udev_init(void)
{
  int ret;

  //----------申请设备号-------------
  if (major > 0) { /* 静态设备号 */
    devno = MKDEV(major, minor);//转换成 dev_t 类型的设备编号
    ret = register_chrdev_region(devno, 1, "char_null_udev");
  } else { /* 动态设备号 */
    ret = alloc_chrdev_region(&devno, minor, 1, "char_null_udev"); /* 从系统获取主设备号 */
    major = MAJOR(devno);
  }
  if (ret < 0) {
    printk(KERN_ERR "cannot get major %d \n", major);
    return -1;
  }

  //-----------注册驱动设备----------------
  char_null_udev = cdev_alloc(); /* 分配 char_null_udev 结构 */
  if (char_null_udev != NULL) {
    cdev_init(char_null_udev, &major); /* 初始化 char_null_udev 结构 */
    char_null_udev->owner = THIS_MODULE;
    if (cdev_add(char_null_udev, devno, 1) != 0) { /* 增加 char_null_udev 到系统中 */
      printk(KERN_ERR "add cdev error!\n");
      goto error;
    }
  } else {
    printk(KERN_ERR "cdev_alloc error!\n");
    return -1;
  }

  //---------引入udev 作为动态设备管理器----------------
  //在/sys/class/下创建 char_null_udev_class 目录
  char_null_udev_class = class_create(THIS_MODULE, "char_null_udev_class");
  if (IS_ERR(char_null_udev_class)) {
    printk(KERN_INFO "create class error\n");
    return -1;
  }
  /* 将创建/dev/char_null_udev0 文件 */
  //device_create(char_null_udev_class, NULL, devno, NULL, "char_null_udev" "%d",MINOR(devno));
  /* 将创建/dev/char_null_udev 文件 */
  device_create(char_null_udev_class, NULL, devno, NULL, "char_null_udev");

  return 0;

error:
  unregister_chrdev_region(devno, 1); /* 释放已经获得的设备号 */
  return ret;
}

static void __exit char_null_udev_exit(void)
{
  device_destroy(char_null_udev_class, devno); //销毁设备节点文件
  class_destroy(char_null_udev_class);//销毁类
  cdev_del(char_null_udev); /* 移除字符设备 */
  unregister_chrdev_region(devno, 1); /* 释放设备号 */
}

module_init(char_null_udev_init);
module_exit(char_null_udev_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Chenxibing, linux@zlgmcu.com");
```

编译代码后得到 char_null_udev.ko 模块，插入系统，将可以在/sys/class 目录下看到char_null _udev 目录以及其它信息 



### 设备驱动的操作方法 

#### fops 核心数据结构

file_operations 结构是一系列指针的集合， 用来存储对设备提供各种操作的函数的指针，
这些操作函数通常被称之为方法。 

```c
struct file_operations {
  struct module *owner;
  loff_t (*llseek) (struct file *, loff_t, int);
  ssize_t (*read) (struct file *, char __user *, size_t, loff_t *);
  ssize_t (*write) (struct file *, const char __user *, size_t, loff_t *);
  ssize_t (*aio_read) (struct kiocb *, const struct iovec *, unsigned long, loff_t);
  ssize_t (*aio_write) (struct kiocb *, const struct iovec *, unsigned long, loff_t);
  int (*readdir) (struct file *, void *, filldir_t);
  unsigned int (*poll) (struct file *, struct poll_table_struct *);
  int (*ioctl) (struct inode *, struct file *, unsigned int, unsigned long);
  long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
  long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
  int (*mmap) (struct file *, struct vm_area_struct *);
  int (*open) (struct inode *, struct file *);
  int (*flush) (struct file *, fl_owner_t id);
  int (*release) (struct inode *, struct file *);
  int (*fsync) (struct file *, struct dentry *, int datasync);
  int (*aio_fsync) (struct kiocb *, int datasync);
  int (*fasync) (int, struct file *, int);
  int (*lock) (struct file *, int, struct file_lock *);
  ssize_t (*sendpage) (struct file *, struct page *, int, size_t, loff_t *, int);
  unsigned long (*get_unmapped_area)(struct file *, unsigned long, unsigned long,
                                     unsigned long, unsigned long);
  int (*check_flags)(int);
  int (*dir_notify)(struct file *filp, unsigned long arg);
  int (*flock) (struct file *, int, struct file_lock *);
  ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
  ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
  int (*setlease)(struct file *, long, struct file_lock **);
}
```

file_oprations 结构中定义了非常多的成员， 但是对于大多数字符驱动而言， 只需要实现
其中很少的几个方法即可。 

常用成员 

- owner 属主 

  - ```c
    struct module *owner
    //用来在它的操作还在被使用时阻止模块被卸载，通常初始化为 THIS_MODULE。
    ```

- read 方法 

  - ```c
    ssize_t (*read) (struct file *, char __user *, size_t, loff_t *);
    //从设备中获取数据。非负返回值表示成功读取的字节数
    ```

- write 方法 

  - ```c
    ssize_t (*write) (struct file *, const char __user *, size_t, loff_t *);
    //发送数据给设备。非负返回值表示成功写入的字节数。
    ```

- open 方法 

  - ```c
    int (*open) (struct inode *, struct file *);
    //对应于设备的打开操作。
    ```

- release 方法 

  - ```c
    int (*release) (struct inode *, struct file *);
    //对应于设备的关闭操作
    ```

- ioctl 

  - ```c
    int (*ioctl) (struct inode *, struct file *, unsigned int, unsigned long);
    ```

    ​

#### 为驱动定义 fops 

若要编写一个具有实际操作方法的驱动，首先得为驱动定义一个 file_operations 结构，
通常称为 fops，在其中定义将要实现的各种方法。 

要在 char_cdev 的驱动中实现 open、release、 read、 write 和 ioctl 方法 

```c
struct file_operations char_cdev_fops = {
  .owner = THIS_MODULE,
  .read = char_cdev_read,
  .write = char_cdev_write,
  .open = char_cdev_open,
  .release = char_cdev_release,
  .ioctl = char_cdev_ioctl
};
```



#### 为设备关联fops

即注册设备，同一个函数

```c
void cdev_init(struct cdev *cdev, const struct file_operations *fops)
//cdev_init(char_cdev, &char_cdev_fops); //初始化 char_cdev 结构
```

cdev_init()将定义好的 char_cdev_fops 的地址赋给 char_cdev 的 fops 指针，将定义的驱动
操作方法与某个主设备号关联起来。当 open 系统调用打开某个设备，能够得知设备的主设
备号，也就知道该用哪一组方法来操作这个设备。  

![](https://note.youdao.com/yws/public/resource/ea43181f60c17fcc4449163ab62b9e2c/xmlnote/WEBRESOURCEaae534f98e02e6c77b28ca4fd369a24d/9524)



#### 驱动的方法和系统调用 

设备注册后，该设备的主设备号与 fops 之间对应关系就一直存在于内核中，直到驱动生命周
期结束（被卸载） ,应用程序发起系统调用，内核根据这个对应关系寻找正确的驱动程序来
执行相关操作 .

![](https://note.youdao.com/yws/public/resource/ea43181f60c17fcc4449163ab62b9e2c/xmlnote/WEBRESOURCEf0fc1becc32a52556ec74d25cb0dc8cf/9526)

用户程序系统调用打开/dev/char 设备文件，获得主次设备号；（主设备号决定打开的设备函数，次设备号决定操作的具体设备）

根据主设备号，寻找对应的fopt；

找到对应的fopt，执行驱动的xxx_open方法的代码。



## 字符设备驱动框架 

![](https://note.youdao.com/yws/public/resource/ea43181f60c17fcc4449163ab62b9e2c/xmlnote/WEBRESOURCE09ab2bbf6d6e6c733a4618c4c0ea2df3/9528)

```c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/device.h>

static int major = 232; /* 静态设备号方式的默认值 */
static int minor = 0; /* 静态设备号方式的默认值 */
module_param(major, int, S_IRUGO);//引入驱动参数
module_param(minor, int, S_IRUGO);

struct cdev *char_cdev; /* cdev 数据结构 */
static dev_t devno; /* 设备编号 */
static struct class *char_cdev_class;

#define DEVICE_NAME "char_cdev"//设备名称

static int char_cdev_open(struct inode *inode, struct file *file )
{
  try_module_get(THIS_MODULE);
  printk(KERN_INFO DEVICE_NAME " opened!\n");
  return 0;
}

static int char_cdev_release(struct inode *inode, struct file *file )
{
  printk(KERN_INFO DEVICE_NAME " closed!\n");
  module_put(THIS_MODULE);
  return 0;
}

static ssize_t char_cdev_read(struct file *file, char *buf,size_t count, loff_t *f_pos)
{
  printk(KERN_INFO DEVICE_NAME " read method!\n");
  return count;
}

static ssize_t char_cdev_write(struct file *file, const char *buf, size_t count, loff_t *f_pos)
{
  printk(KERN_INFO DEVICE_NAME " write method!\n");
  return count;
}

static int char_cdev_ioctl(struct inode *inode, struct file *file, unsigned int cmd, unsigned long arg)
{
  printk(KERN_INFO DEVICE_NAME " ioctl method!\n");
  return 0;
}

struct file_operations char_cdev_fops = {
  .owner = THIS_MODULE,
  .read = char_cdev_read,
  .write = char_cdev_write,
  .open = char_cdev_open,
  .release = char_cdev_release,
  .ioctl = char_cdev_ioctl
};

static int __init char_cdev_init(void)
{
  int ret;

  //---------------申请设备号-----------------
  if (major > 0) { /* 静态设备号 */
    devno = MKDEV(major, minor);
    ret = register_chrdev_region(devno, 1, "char_cdev");
  } else { /* 动态设备号 */
    ret = alloc_chrdev_region(&devno, minor, 1, "char_cdev"); /* 从系统获取主设备号 */
    major = MAJOR(devno);
  }
  if (ret < 0) {
    printk(KERN_ERR "cannot get major %d \n", major);
    return -1;
  }

  //---------------注册设备-----------------
  char_cdev = cdev_alloc(); /* 分配 char_cdev 结构 */
  if (char_cdev != NULL) {
    cdev_init(char_cdev, &char_cdev_fops); /* 初始化 char_cdev 结构 */
    char_cdev->owner = THIS_MODULE;
    if (cdev_add(char_cdev, devno, 1) != 0) { /* 增加 char_cdev 到系统中 */
      printk(KERN_ERR "add cdev error!\n");
      goto error;
    }
  } else {
    printk(KERN_ERR "cdev_alloc error!\n");
    return -1;
  }

  //---------引入动态设备管理器----------------
  char_cdev_class = class_create(THIS_MODULE, "char_cdev_class");
  if (IS_ERR(char_cdev_class)) {
    printk(KERN_INFO "create class error\n");
    return -1;
  }

  //device_create(char_cdev_class, NULL, devno, NULL, "char_cdev" "%d", MINOR(devno));
  device_create(char_cdev_class, NULL, devno, NULL, "char_cdev", NULL);
  return 0;

error:
  unregister_chrdev_region(devno, 1); /* 释放已经获得的设备号 */
  return ret;
}

static void __exit char_cdev_exit(void)
{
  cdev_del(char_cdev); /* 移除字符设备 */
  unregister_chrdev_region(devno, 1); /* 释放设备号 */
  device_destroy(char_cdev_class, devno);
  class_destroy(char_cdev_class);
}

module_init(char_cdev_init);
module_exit(char_cdev_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Chenxibing, linux@zlgmcu.com");
```



字符驱动测试程序 

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <fcntl.h>

#define DEV_NAME "/dev/char_cdev"

int main(int argc, char *argv[])
{
  int i;
  int fd = 0;
  int dat = 0;

  fd = open (DEV_NAME, O_RDWR);
  if (fd < 0) {
    perror("Open "DEV_NAME" Failed!\n");
    exit(1);
  }

  i = read(fd, &dat, 1);
  if (!i) {
    perror("read "DEV_NAME" Failed!\n");
    exit(1);
  }

  dat = 0;
  i = write(fd, &dat, 1);
  if (!i) {
    perror("write "DEV_NAME" Failed!\n");
    exit(1);
  }

  i = ioctl(fd, NULL, NULL);
  if (!!i) {
    perror("ioctl "DEV_NAME" Failed!\n");
    exit(1);
  }

  close(fd);
  return 0;
}
```



## 第一个完整意义上的驱动 

以 LED 驱动为例，通过点亮或者熄灭指示灯，以指示不同的运行状态信息 。



### 内核空间的 ioctl 

```c
int (*ioctl) (struct inode *inode, struct file *filp, unsigned int cmd, unsigned long arg);
```

定义的 ioctl 命令通过 cmd 传递，数据通过 arg 传递。驱动得到 cmd 命令和 arg 参数后，须首先用解析 ioctl 命令的宏定义对命令和参数进行解析判断，没有问题再进行后续处理。 



### 用户空间的 ioctl 

```c
int ioctl (int fd, unsigned long cmd, ...)
//fd 是被打开的设备文件， cmd 是操作设备的命令，“...”代表可变数目的参数表 。
```



### 构造 ioctl 命令 

首先要为驱动选择一个可用的幻数作为驱动的特征码，以区分不同驱动的命令。 

```c
#define LED_IOC_MAGIC 'Z
```



ioctl 命令 对应以下宏定义：

```c
_IO(type, nr) 构造无参数的命令编号
_IOW(type, nr, size) 构造往驱动写入数据的命令编号
_IOR(type, nr, size) 构造从驱动中读取数据的命令编号
_IOWR(type, nr, size) 构造双向传输的命令编号
//type是幻数，nr是命令编码
```

例如，为 LED 驱动构造 ioctl 命令 

```c
#define SET_LED_ON _IO(LED_IOC_MAGIC, 0)
#define SET_LED_OFF _IO(LED_IOC_MAGIC, 1)
#define CHAR_WRITE_DATA _IOW(CHAR_IOC_MAGIC, 2, int)
#define CHAR_READ_DATA _IOR(CHAR_IOC_MAGIC, 3, int)
```

注意：同一份驱动的 ioctl 命令定义，无论有无数据传输以及数据传输方向是否相同，各命令的序号都不能相同。 



### 解析 ioctl 命令 

驱动程序必须对传入的命令进行解析，包括传输方向、命令类型、命令编号以及参数大小，分别可以通过下面的宏定义完成： 

```c
_IOC_DIR(nr) 解析命令的传输方向
_IOC_TYPE(nr) 解析命令类型
_IOC_NR(nr) 解析命令序号
_IOC_SIZE(nr) 解析参数大小
```

如果解析发现命令出错，可以返回-ENOTTY 

```c
if (_IOC_TYPE(cmd) != LED_IOC_MAGIC) 
  return -ENOTTY;
if (_IOC_NR(cmd) >= LED_IOC_MAXNR) {
  return -ENOTTY;
}
```



### LED 驱动范例 

对 LED 设备驱动，采用 ioctl 方法实现，首先需要定义 ioctl 的操作命令。

led_drv.h 文件

```c
#ifndef _LED_DRV_H
#define _LED_DRV_H

#define LED_IOC_MAGIC 'L'	//定义幻数
#define LED_ON _IO(LED_IOC_MAGIC, 0)	//构造ioctl命令
#define LED_OFF _IO(LED_IOC_MAGIC, 1)

#define LED_IOCTL_MAXNR 2	//定义最大命令编码

#endif /*_LED_DRV_H*/
```

led.c 驱动文件

```c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/version.h>

#include <asm/mach/arch.h>
#include <mach/hardware.h>
#include <mach/gpio.h>
#include <asm/gpio.h>

#include "led_drv.h"

static int major;
static int minor;
struct cdev *led; /* cdev 数据结构 */
static dev_t devno; /* 设备编号 */
static struct class *led_class;

#define DEVICE_NAME "led"

#define GPIO_LED_PIN_NUM 55 /* gpio 1_23 */

//操作方法实现
static int led_open(struct inode *inode, struct file *file )
{
  try_module_get(THIS_MODULE);
  gpio_direction_output(GPIO_LED_PIN_NUM, 1);//IO口设置为输出
  return 0;
}

static int led_release(struct inode *inode, struct file *file )
{
  module_put(THIS_MODULE);
  gpio_direction_output(GPIO_LED_PIN_NUM, 1);
  return 0;
}

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,36)
int led_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
#else
static int led_ioctl(struct inode *inode, struct file *file, unsigned int cmd, unsigned long arg)
#endif
{
  if (_IOC_TYPE(cmd) != LED_IOC_MAGIC) {//对传入的命令进行解析
    return -ENOTTY;
  }

  if (_IOC_NR(cmd) > LED_IOCTL_MAXNR) {
    return -ENOTTY;
  }

  switch(cmd) {
    case LED_ON:	//判断命令
      gpio_set_value(GPIO_LED_PIN_NUM, 0);
      break;

    case LED_OFF:
      gpio_set_value(GPIO_LED_PIN_NUM, 1);
      break;

    default:
      gpio_set_value(27, 0);
      break;
  }

  return 0;
}

//定义file_operations结构体，实现char_cdev 对应的驱动具体方法
struct file_operations led_fops = {
  .owner = THIS_MODULE,
  .open = led_open,
  .release = led_release,
  #if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,36)
  .unlocked_ioctl = led_ioctl
    #else
    .ioctl = led_ioctl
    #endif
};

static int __init led_init(void)//驱动初始化部分
{
  int ret;

  gpio_free(GPIO_LED_PIN_NUM);
  if (gpio_request(GPIO_LED_PIN_NUM, "led_run")) {
    printk("request %s gpio faile \n", "led_run");
    return -1;
  }

  //---------------申请主设备号---------------------
  ret = alloc_chrdev_region(&devno, minor, 1, "led"); /* 从系统获取主设备号 */
  major = MAJOR(devno);
  if (ret < 0) {
    printk(KERN_ERR "cannot get major %d \n", major);
    return -1;
  }

  //---------------注册设备-----------------
  led = cdev_alloc(); /* 分配 led 结构 */
  if (led != NULL) {
    cdev_init(led, &led_fops); /* 初始化 led 结构 */
    led->owner = THIS_MODULE;
    if (cdev_add(led, devno, 1) != 0) { /* 增加 led 到系统中 */
      printk(KERN_ERR "add cdev error!\n");
      goto error;
    }
  } else {
    printk(KERN_ERR "cdev_alloc error!\n");
    return -1;
  }

  //---------引入动态设备管理器----------------
  led_class = class_create(THIS_MODULE, "led_class");
  if (IS_ERR(led_class)) {
    printk(KERN_INFO "create class error\n");
    return -1;
  }

  device_create(led_class, NULL, devno, NULL, "led");
  return 0;

  error:
  unregister_chrdev_region(devno, 1); /* 释放已经获得的设备号 */
  return ret;
}

static void __exit led_exit(void)//驱动退出部分
{
  cdev_del(led); /* 移除字符设备 */
  unregister_chrdev_region(devno, 1); /* 释放设备号 */
  device_destroy(led_class, devno);
  class_destroy(led_class);
}

module_init(led_init);
module_exit(led_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Chenxibing, linux@zlgmcu.com");
```



测试程序 

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <fcntl.h>
#include "../led_drv.h"

#define DEV_NAME "/dev/led
int main(int argc, char *argv[])
{
  int i;
  int fd = 0;

  fd = open (DEV_NAME, O_RDONLY);
  if (fd < 0) {
    perror("Open "DEV_NAME" Failed!\n");
    exit(1);
  }

  for (i=0; i<3; i++) {
    ioctl(fd, LED_ON);
    sleep(1);
    ioctl(fd, LED_OFF);
    sleep(1);
  }

  close(fd);
  return 0;
}
```



## 内核/用户空间的数据交换 

即是在驱动中对read和write方法的具体实现。



用户空间通过read、write和ioctl与内核空间（驱动）进行数据交互；

对于驱动代码而言，需要使用put_user/get_user、copy_to_user/copy_from_user等方法实现read、write的方法，达到交互。




### 往用户空间传递数据 

- 传递单个数据 

```c
int put_user(x,p)
//put_user 一次性可传递一个 char、 short 或者 int 型的数据，即 1、2 或者 4 字节。
//x 为内核空间的数据， p 为用户空间的指针。 传递成功，返回 0，否则返回-EFAULT。
```

```c
static int char_cdev_ioctl (struct inode *inode, struct file *filp, unsigned int cmd, unsigned long arg)
{
  int ret;
  u32 dat,
  switch(cmd)
  {
    case CHAR_CDEV_READ:
      ...其它操作
        dat = 数据；
        if (put_user(dat, (u32 *)arg) ) {
          printk("put_user err\n");
          return -EFAULT;
        }
  }
  ...其它操作
    return ret;
}
```



- 传递多个数据 

```c
static inline unsigned long __must_check copy_to_user(void *to, const void __user *from, unsigned long n);
//参数 to 是用户空间地址， from 是内核空间缓冲区地址， n 是数据字节数，返回值是不能被复制的字节数，返回 0 表示全部复制成功。
```

```c
static ssize_t char_cdev_read(struct file *filp, char __user *buf, size_t count, loff_t *ppos)
{
  unsigned char data[256] = {0};
  ....从设备获取数据
  if (copy_to_user((void *)buf, data, count)) {
    printk("copy_to_user err\n");
    return -EFAULT;
  }
  return count;
}
```



### 从用户空间获取数据 

- 获取单个数据 

```c
int get_user(x, p)
//get_user 一次性可获取一个 char、 short 或者 int 型的数据，即 1、 2 或者 4 字节.
//x 为内核空间的数据， p 为用户空间的指针。 获取成功，返回 0，否则返回-EFAULT。
```

```c
static int char_cdev_ioctl (struct inode *inode, struct file *filp, unsigned int cmd, unsigned long arg)
{
  int ret;
  u32 dat,
  switch(cmd)
  {
    case CHAR_CDEV_WRITE:
      if (get_user(dat, (u32 *)arg) ) {
        printk("get_user err\n");
        return -EFAULT;
      }
      CHAR_CDEV_REG = dat;
      ...其它操作
  }
  ...其它操作
    return ret;
}
```



- 获取多个数据 

```c
static inline unsigned long __must_check copy_from_user(void *to, const void __user *from, unsigned long n);
//参数 to 是内核空间缓冲区地址， from 是用户空间地址， n 是数据字节数，返回值是不能被复制的字节数，返回 0 表示全部复制成功。
```

```c
static ssize_t char_cdev_write(struct file *filp, const char __user *buf, size_t count, loff_t *ppos)
{
  unsigned char data[256];
  if (copy_from_user(&data, buf, 256) ) {
    printk("copy_from_user err\n");
    return -EFAULT;
  }
  ...
}
```



### 支持读写的驱动示例 

驱动程序 char_cdev_rw.c

```c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <asm/uaccess.h> /* copy_to_user ... */

static int major;
static int minor;
struct cdev *char_cdev_rw; /* cdev 数据结构 */
static dev_t devno; /* 设备编号 */
static struct class *char_cdev_rw_class;
static char dev_rw_buff[64]; /* 设备内部读写缓冲区 */

#define DEVICE_NAME "char_cdev_rw"

static int char_cdev_rw_open(struct inode *inode, struct file *file )
{
  try_module_get(THIS_MODULE);
  return 0;
}

static int char_cdev_rw_release(struct inode *inode, struct file *file )
{
  module_put(THIS_MODULE);
  return 0;
}

static ssize_t char_cdev_rw_read(struct file *file, char *buf,size_t count, loff_t *f_pos)
{
  if (count > 64) {
    printk("Max length is 64\n");
    count = 64;
  }

  if (copy_to_user((void *)buf, dev_rw_buff, count)) {
    printk("copy_to_user err\n");
    return -EFAULT;
  }

  return count;
}

static ssize_t char_cdev_rw_write(struct file *file, const char *buf, size_t count, loff_t *f_pos)
{
  if (count > 64) {
    printk("Max length is 64\n");
    count = 64;
  }

  if (copy_from_user(&dev_rw_buff, buf, count) ) {
    printk("copy_from_user err\n");
    return -EFAULT;
  }

  return count;
}

struct file_operations char_cdev_rw_fops = {
  .owner = THIS_MODULE,
  .read = char_cdev_rw_read,
  .write = char_cdev_rw_write,
  .open = char_cdev_rw_open,
  .release = char_cdev_rw_release,
};

static int __init char_cdev_rw_init(void)
{
  int ret;
  int i;

  ret = alloc_chrdev_region(&devno, minor, 1, "char_cdev_rw"); /* 从系统获取主设备号 */
  major = MAJOR(devno);
  if (ret < 0) {
    printk(KERN_ERR "cannot get major %d \n", major);
    return -1;
  }

  char_cdev_rw = cdev_alloc(); /* 分配 char_cdev_rw 结构 */
  if (char_cdev_rw != NULL) {
    cdev_init(char_cdev_rw, &char_cdev_rw_fops); /* 初始化 char_cdev_rw 结构 */
    char_cdev_rw->owner = THIS_MODULE;
    if (cdev_add(char_cdev_rw, devno, 1) != 0) { /* 增加 char_cdev_rw 到系统中 */
      printk(KERN_ERR "add cdev error!\n");
      goto error;
    }
  } else {
    printk(KERN_ERR "cdev_alloc error!\n");
    return -1;
  }

  char_cdev_rw_class = class_create(THIS_MODULE, "char_cdev_rw_class");
  if (IS_ERR(char_cdev_rw_class)) {
    printk(KERN_INFO "create class error\n");
    return -1;
  }

  device_create(char_cdev_rw_class, NULL, devno, NULL, "char_cdev_rw");

  for (i=0; i<64; i++) {
    dev_rw_buff[i] = i; /* 初始化设备内部读写缓冲区 */
  }

  return 0; 
error:
  unregister_chrdev_region(devno, 1); /* 释放已经获得的设备号 */
  return ret;
}

static void __exit char_cdev_rw_exit(void)
{
  cdev_del(char_cdev_rw); /* 移除字符设备 */
  unregister_chrdev_region(devno, 1); /* 释放设备号 */
  device_destroy(char_cdev_rw_class, devno);
  class_destroy(char_cdev_rw_class);
}

module_init(char_cdev_rw_init);
module_exit(char_cdev_rw_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Chenxibing, linux@zlgmcu.com");
```

测试程序 char_dev_rw_test.c

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <fcntl.h>

#define DEV_NAME "/dev/char_cdev_rw"

int main(int argc, char *argv[])
{
  int i;
  int fd = 0;
  char buff[64];

  fd = open (DEV_NAME, O_RDWR);
  if (fd < 0) {
    perror("Open "DEV_NAME" Failed!\n");
    exit(1);
  }

  printf("read orig data from device\n");
  i = read(fd, &buff, 64);
  if (!i) {
    perror("read "DEV_NAME" Failed!\n");
    exit(1);
  }
  for (i=0; i<64; i++ ) {
    printf("0x%02x ", buff[i]);
  }
  printf("\n");

  printf("write data into device\n");
  for (i=0; i<64; i++ ) {
    buff[i] = 63 - i;
  }
  i = write(fd, &buff, 64);
  if (!i) {
    perror("write "DEV_NAME" Failed!\n");
    exit(1);
  }

  printf("read new data from device\n");
  i = read(fd, &buff, 64);
  if (!i) {
    perror("read "DEV_NAME" Failed!\n");
    exit(1);
  }
  for (i=0; i<64; i++ ) {
    printf("0x%02x ", buff[i]);
  }
  printf("\n");

  close(fd);
  return 0;
}
```

测试方法

```shell
$ insmod char_cdev_rw.ko
$ ./char_dev_rw_test
```



## 在驱动中使用中断 

在驱动中使用中断，先申请中断号，并注册一个中断中断处理程序，在中断程序实现对外部事件的处理。 



### 申请中断 

```c
static inline int __must_check request_irq(unsigned int irq, irq_handler_t handler, unsigned long flags,const char *name, void *dev);
//irq 要申请的硬件中断号。
//handler 实际中断处理程序的函数指针
//flags 设置与中断有关的一些选项
//*name 用来在/proc/interrupts 显示中断的拥有者
//*dev 中断处理程序可以用 dev 找到相应的控制这个中断的设备。
```

### 释放中断 

```c
void free_irq(unsigned int irq, void *dev_id)
//第一个参数是将要释放的 irq 中断号。
//第二个参数标志设备。如果中断是该设备独占的，这里设置为 NULL；如果是共享中断，需要设置为中断处理程序指针。
```

### 设置触发条件 

上升沿中断或者下降沿中断等 

```c
extern int irq_set_irq_type(unsigned int irq, unsigned int type);
//irq 为中断号， type 为终端类型。
```

type类型

```c
IRQ_TYPE_NONE = 0x00000000,
IRQ_TYPE_EDGE_RISING = 0x00000001,
IRQ_TYPE_EDGE_FALLING = 0x00000002,
IRQ_TYPE_EDGE_BOTH = (IRQ_TYPE_EDGE_FALLING | IRQ_TYPE_EDGE_RISING),
IRQ_TYPE_LEVEL_HIGH = 0x00000004,
IRQ_TYPE_LEVEL_LOW = 0x00000008,
IRQ_TYPE_LEVEL_MASK = (IRQ_TYPE_LEVEL_LOW | IRQ_TYPE_LEVEL_HIGH),
IRQ_TYPE_SENSE_MASK = 0x0000000f,
IRQ_TYPE_PROBE = 0x00000010,
```

### 使能和禁止中断 

```
extern void enable_irq(unsigned int irq);
//irq 为需要使能的中断号。
```

### 禁止中断 

```c
extern void disable_irq(unsigned int irq);
```

### 中断处理函数

```c
typedef irqreturn_t (*irq_handler_t)(int irq, void *dev_id);
//中断处理完毕，通常返回 IRQ_HANDLED。
```

```c
static irqreturn_t xxxx_interrupt(int irq, void *dev_id)
{
  ...中断处理代码
  return IRQ_HANDLED; /* 中断已经处理完毕 */
}
```



### 按键终端驱动示例 

```c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/interrupt.h>
#include <linux/irq.h>
#include <linux/gpio.h>

#define KEY_GPIO 70 /* GPIO2_6 */
#define KEY_GPIO_IRQ gpio_to_irq(KEY_GPIO) /* 中断号 */
#define DEVICE_NAME "key_irq"

static int major;
static int minor;
struct cdev *key_irq; /* cdev 数据结构 */
static dev_t devno; /* 设备编号 */
static struct class *key_irq_class;

char const irq_types[5] = {
  IRQ_TYPE_EDGE_RISING,
  IRQ_TYPE_EDGE_FALLING,
  IRQ_TYPE_EDGE_BOTH,
  IRQ_TYPE_LEVEL_HIGH,
  IRQ_TYPE_LEVEL_LOW
};
static int key_irq_open(struct inode *inode, struct file *file )
{
  try_module_get(THIS_MODULE);
  printk(KERN_INFO DEVICE_NAME " opened!\n");
  return 0;
}

static int key_irq_release(struct inode *inode, struct file *file )
{
  printk(KERN_INFO DEVICE_NAME " closed!\n");
  module_put(THIS_MODULE);
  return 0;
}

static irqreturn_t key_irq_irq_handler (unsigned int irq, void *dev_id)
{
  printk("KEY IRQ HAPPENED!\n");
  return IRQ_HANDLED;
}
struct file_operations key_irq_fops = {
  .owner = THIS_MODULE,
  .open = key_irq_open,
  .release = key_irq_release,
};

static int __init key_irq_init(void)
{
  int ret;

  gpio_free(KEY_GPIO);
  ret = gpio_request_one(KEY_GPIO, GPIOF_IN, "KEY IRQ"); /* 申请 IO */
  if (ret < 0) {
    printk(KERN_ERR "Failed to request GPIO for KEY\n");
  }

  gpio_direction_input(KEY_GPIO); /* 设置 GPIO 为输入 */
  if (request_irq(KEY_GPIO_IRQ, key_irq_irq_handler, IRQF_DISABLED, "key_irq irq", NULL) )
  { /* 申请中断 */
    printk(KERN_WARNING DEVICE_NAME": Can't get IRQ: %d!\n", KEY_GPIO_IRQ);
  }
  set_irq_type(KEY_GPIO_IRQ, irq_types[1]);
  disable_irq(KEY_GPIO_IRQ);
  enable_irq(KEY_GPIO_IRQ);

  ret = alloc_chrdev_region(&devno, minor, 1, DEVICE_NAME); /* 从系统获取主设备号 */
  major = MAJOR(devno);
  if (ret < 0) {
    printk(KERN_ERR "cannot get major %d \n", major);
    return -1;
  }

  key_irq = cdev_alloc(); /* 分配 key_irq 结构 */
  if (key_irq != NULL) {
    cdev_init(key_irq, &key_irq_fops); /* 初始化 key_irq 结构 */
    key_irq->owner = THIS_MODULE;
    if (cdev_add(key_irq, devno, 1) != 0) { /* 增加 key_irq 到系统中 */
      printk(KERN_ERR "add cdev error!\n");
      goto error;
    }
  } else {
    printk(KERN_ERR "cdev_alloc error!\n");
    return -1;
  }

  key_irq_class = class_create(THIS_MODULE, "key_irq_class");
  if (IS_ERR(key_irq_class)) {
    printk(KERN_INFO "create class error\n");
    return -1;
  }

  device_create(key_irq_class, NULL, devno, NULL, DEVICE_NAME);
  return 0;

  error:
  unregister_chrdev_region(devno, 1); /* 释放已经获得的设备号 */
  return ret;
}

static void __exit key_irq_exit(void)
{
  gpio_free(KEY_GPIO);
  disable_irq(KEY_GPIO_IRQ);
  free_irq(KEY_GPIO_IRQ, NULL);
  cdev_del(key_irq); /* 移除字符设备 */
  unregister_chrdev_region(devno, 1); /* 释放设备号 */
  device_destroy(key_irq_class, devno);
  class_destroy(key_irq_class);
}

module_init(key_irq_init);
module_exit(key_irq_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Chenxibing, linux@zlgmcu.com");
```

驱动测试 

编译驱动后， 将驱动模块插入系统， 然后按下按键， 可以看到按键中断发生并打印提示信息 

```shell
$ insmod key_irq.ko
KEY IRQ HAPPENED!
```

查看/proc/interrupts 文件， 可以看到中断的发生次数

```c
cat /proc/interrupts

220: 26 GPIO key_irq irq
```



## 混杂设备驱动编程 

2.6 内核的驱动按照各类设备的特性，在 cdev 基础上进行了进一步封装，增加了各类设备的特性功能管理，抽象出了多子系统，如 input、 usb、 scsi、 sound 和 framebuffer 等。基于子系统编程，子系统能够完成与 sysfs 的交互，直接生成设备节点，简化了驱动编程。 



混杂设备（misc decive），是一些无法按照特定子系统的特性进行抽象的一些设备，在内核中用 miscdevice 来描述。 所有的混杂设备被用同一个主设备号MISC_MAJOR(10)，每个设备只能选择自己的次设备号。 

- 定义miscdevice 结构 

```c
struct miscdevice {
  int minor;//次设备号
  const char *name;
  const struct file_operations *fops;
  struct list_head list;
  struct device *parent;
  struct device *this_device;
};
```

- 混杂设备注册 

```c
int misc_register(struct miscdevice * misc);
```

（把申请主设备号，申请和初始化cdev结构的过程简化了）

- 混杂设备注销

```c
int misc_deregister(struct miscdevice *misc);
```



### 混杂设备驱动框架 

```c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/miscdevice.h>

#define DEVICE_NAME "char_misc"

static int char_misc_open(struct inode *inode, struct file *file )
{
  try_module_get(THIS_MODULE);
  printk(KERN_INFO DEVICE_NAME "opened!\n");
  return 0;
}

static int char_misc_release(struct inode *inode, struct file *file )
{
  printk(KERN_INFO DEVICE_NAME "closed!\n");
  module_put(THIS_MODULE);
  return 0;
}

static ssize_t char_misc_read(struct file *file, char *buf,size_t count, loff_t *f_pos)
{
  printk(KERN_INFO DEVICE_NAME "read method!\n");
  return count;
}

static ssize_t char_misc_write(struct file *file, const char *buf, size_t count, loff_t *f_pos)
{
  printk(KERN_INFO DEVICE_NAME "write method!\n");
  return count;
}

static int char_misc_ioctl(struct inode *inode, struct file *file, unsigned int cmd, unsigned long arg)
{
  printk(KERN_INFO DEVICE_NAME "ioctl method!\n");
  return 0;
}
struct file_operations char_misc_fops = {
  .owner = THIS_MODULE,
  .read = char_misc_read,
  .write = char_misc_write,
  .open = char_misc_open,
  .release = char_misc_release,
  .ioctl = char_misc_ioctl
};

/* misc 结构体定义和初始化 */
static struct miscdevice char_misc = {
  .minor = MISC_DYNAMIC_MINOR,
  .name = DEVICE_NAME,
  .fops = &char_misc_fops,
};

static int __init char_misc_init(void)
{
  int ret;

  ret = misc_register(&char_misc); /* 注册 misc 设备 */
  if (ret < 0) {
    printk(KERN_ERR "misc_register error!\n");
    return -1;
  }

  return 0;
}

static void __exit char_misc_exit(void)
{
  misc_deregister(&char_misc); /* 卸载 misc 设备 */
}

module_init(char_misc_init);
module_exit(char_misc_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Chenxibing, linux@zlgmcu.com");

```

编译后得到 char_misc.ko 模块，插入内核，可以看到/dev/char_misc 文件，查看详细信息 。

```shell
$ ls /dev/char_misc -l
crw------- 1 root root 10, 55 2011-01-22 09:39 /dev/char_misc
```



## Linux 设备驱动模型 

设备驱动模型，对系统的所有设备和驱动进行了抽象，形成了复杂的设备树型结构，采用面向对象的方法，抽象出了 device 设备、 driver 驱动、 bus 总线和 class 类等概念，所有已经注册的设备和驱动都挂在总线上，总线来完成设备和驱动之间的匹配。 



### 设备  device

在 Linux 设备驱动模型中，底层用 device 结构来描述所管理的设备。 

```c
struct device {
  struct device *parent; /* 父设备 */
  struct device_private *p; /* 设备的私有数据 */
  struct kobject kobj; /* 设备的 kobject 对象 */
  const char *init_name; /* 设备的初始名字 */
  struct device_type *type; /* 设备类型 */
  struct mutex mutex; /* 同步驱动的互斥信号量 */
  struct bus_type *bus; /* 设备所在的总线类型 */
  struct device_driver *driver; /* 管理该设备的驱动程序 */
  void *platform_data; /* 平台相关的数据 *
  struct dev_pm_info power; /* 电源管理 */
#ifdef CONFIG_NUMA
  int numa_node; /* 设备接近的非一致性存储结构 */
#endif
  u64 *dma_mask; /* DMA 掩码 */
  u64 coherent_dma_mask; /* 设备一致性的 DMA 掩码 */
  struct device_dma_parameters *dma_parms; /* DMA 参数 */
  struct list_head dma_pools; /* DMA 缓冲池 */
  struct dma_coherent_mem *dma_mem; /* DMA 一致性内存 */
  /*体系结构相关的附加项*/
  struct dev_archdata archdata; /* 体系结构相关的数据 */
#ifdef CONFIG_OF
  struct device_node *of_node;
#endif
  dev_t devt; /* 创建 sysfs 的 dev 文件 */
  spinlock_t devres_lock; /* 驱动的锁 */
  struct list_head devres_head;
  struct klist_node knode_class;
  struct class *class; /* 设备所属的类 */
  const struct attribute_group **groups; /* 可选的组 */
  void (*release)(struct device *dev); /* 指向设备的 release 方法*/
};
```

注册和注销 device 

```c
int __must_check device_register(struct device *dev);
void device_unregister(struct device *dev);
```



大多数不会在驱动中单独使用 device 结构，而是将 device 结构嵌入到更高层的描述结构中。 如内核中用 spi_device 来描述 SPI 设备 ，用iic_device描述iic设备。



系统提供了 device_create()函数用于在 sysfs/classs 中创建 dev文件，以供用户空间使用。 

```c
struct device *device_create(struct class *cls, struct device *parent, dev_t devt, void *drvdata, const char *fmt, ...);
/*cls 是指向将要被注册的 class 结构；
 parent 是设备的父指针；
 devt 是设备的设备编号；
 drvdata 是被添加到设备回调的数据；
 fmt 是设备的名字。*/
```

```c
void device_destroy(struct class *cls, dev_t devt);
```



### 驱动 driver

Linux 设备驱动模型中，对管理的驱动也用 device_driver 结构来描述 

```c
struct device_driver {
  const char *name; /* 驱动的名称 */
  struct bus_type *bus; /* 驱动所在的总线 */
  struct module *owner; /* 驱动的所属模块 */
  const char *mod_name; /* 模块名称（静态编译的时候使用） */
  bool suppress_bind_attrs; /* 通过 sysfs 禁止 bind 或者 unbind */
#if defined(CONFIG_OF)
  const struct of_device_id *of_match_table; /* 匹配设备的表 */
#endif
  int (*probe) (struct device *dev); /* probe 探测方法 */
  int (*remove) (struct device *dev); /* remove 方法 */
  void (*shutdown) (struct device *dev); /* shutdown 方法 */
  int (*suspend) (struct device *dev, pm_message_t state); /* suspend 方法 */
  int (*resume) (struct device *dev); /* resume 方法 */
  const struct attribute_group **groups;
  const struct dev_pm_ops *pm; /* 电源管理 */
  struct driver_private *p; /* 驱动的私有数据 */
};
```

系统提供了 driver_register()和 driver_ungister()分别用于注册和注销device_driver 

```c
int __must_check driver_register(struct device_driver *drv);
void driver_unregister(struct device_driver *drv);
```



在驱动中一般也不会单独使用 device_driver 结构，通常也是嵌入在更高层的描述结构中。还是以 SPI 为例，SPI 设备的驱动结构为 spi_driver。



### 总线  bus

在设备驱动模型中，所有的设备都通过总线相连，总线既可以是实际的物理总线，也可以是内核虚拟的 platform 总线。驱动也挂在总线上，总线是设备和驱动之间的媒介。

```c
struct bus_type {
  const char *name; /* 总线名称 */
  struct bus_attribute *bus_attrs; /* 总线属性 */
  struct device_attribute *dev_attrs; /* 设备属性 */
  struct driver_attribute *drv_attrs; /* 驱动属性 */
  int (*match)(struct device *dev, struct device_driver *drv); /* match 方法：匹配设备和驱动 */
  int (*uevent)(struct device *dev, struct kobj_uevent_env *env); /* uevent 方法，支持热插拔 */
  int (*probe)(struct device *dev); /* probe 方法 */
  int (*remove)(struct device *dev); /* remove 方法 */
  void (*shutdown)(struct device *dev); /* shutdown 方法 *
  int (*suspend)(struct device *dev, pm_message_t state); /* suspend 方法 */
  int (*resume)(struct device *dev); /* resume 方法 */
  const struct dev_pm_ops *pm; /* 电源管理 */
  struct bus_type_private *p; /* 总线的私有数据结构 */
};
```

当往总线添加一个新设备或者新驱动的时候， match方法会被调用，为设备或者驱动寻找匹配的驱动程序或者设备。 

注册和注销 bus总线 

```c
int __must_check bus_register(struct bus_type *bus);
void bus_unregister(struct bus_type *bus);
```



### 类  class

类是 Linux 设备驱动模型中的一个高层抽象，为用户空间提供设备的高层视图。 

```c
struct class {
  const char *name; /* 类的名称 */
  struct module *owner; /* 类的所属模块 */
  struct class_attribute *class_attrs; /* 类的属性 */
  struct device_attribute *dev_attrs; /* 设备属性 */
  struct kobject *dev_kobj; /* 类的 kobject 对象 */
  int (*dev_uevent)(struct device *dev, struct kobj_uevent_env *env);
  char *(*devnode)(struct device *dev, mode_t *mode);
  void (*class_release)(struct class *class);
  void (*dev_release)(struct device *dev);
  int (*suspend)(struct device *dev, pm_message_t state);
  int (*resume)(struct device *dev);
  const struct kobj_ns_type_operations *ns_type;
  const void *(*namespace)(struct device *dev);
  const struct dev_pm_ops *pm;
  struct class_private *p;
};
```

注册或者注销一个类的函数 

```c
int __must_check __class_register( struct class *class, struct lock_class_key *key);

void class_unregister(struct class *class);
```

在 sysfs/class 目录下创建或注销自定义的类

```c
extern struct class * __must_check __class_create(struct module *owner,const char *name, struct lock_class_key *key);

extern void class_destroy(struct class *cls)
```



## 平台设备和驱动 

2.6 内核引入了 platform 机制，能够实现对设备所占用的资源进行统一管理。

Platform机制抽象出了 平台设备platform_device 、平台驱动platform_driver 和资源 resource 。



基于 platform 机制编写的驱动与普通字符驱动，只是在框架上有差别，驱动的实际内容是差不多相同的，如果有必要的话，一个普通驱动很容易就可被改写为 platform 驱动。 



普通字符驱动与平台驱动的框架对照 

![](https://note.youdao.com/yws/public/resource/ea43181f60c17fcc4449163ab62b9e2c/xmlnote/WEBRESOURCE345b1bf4abe7600a47ae590f12d659bd/9633)

将一个普通字符驱动改写为平台驱动，驱动各方法方法的实现以及 fops 定义都是一样的，不同之处是框架结构发生了变化，资源的申请和释放等代码的位置发生了变化 



### 资源 

资源 resource 是对设备所占用的硬件信息的抽象，目前包括 I/O、内存、 IRQ、 DMA、BUS 这 5 类。 

```c
struct resource {
  resource_size_t start; /* 资源在 CPU 上的物理起始地址 */
  resource_size_t end; /* 资源在 CPU 上的物理结束地址 */
  const char *name; /* 资源名称 */
  unsigned long flags; /* 资源的标志 */
  struct resource *parent, *sibling, *child; /* 资源的父亲、兄弟和子资源 */
};
```

flags 类型

```c
/* 资源类型 */
#define IORESOURCE_TYPE_BITS 0x00001f00 
#define IORESOURCE_IO 0x00000100//IO资源
#define IORESOURCE_MEM 0x00000200//内存资源
#define IORESOURCE_IRQ 0x00000400//中断资源
#define IORESOURCE_DMA 0x00000800//DMA资源
#define IORESOURCE_BUS 0x00001000//BUS总线资源
```



```c
static struct resource ecm_ax88796b_resource[] = {
  [0] = { /* 内存资源 */
    .start = EMC_CS2_BASE, /* 起始地址 */
    .end = EMC_CS2_BASE + 0xFFF, /* 结束地址 */
    .flags = IORESOURCE_MEM, /* 资源类型： IORESOURCE_MEM */
  },
  [1] = { /* IRQ 资源 */
    .start = IRQ_GPIO_04,
    .end = IRQ_GPIO_04,
    .flags = IORESOURCE_IRQ, /* 资源类型： IORESOURCE_IRQ */
  }
};
```



### 平台设备 platform_device

platform_device 是在系统中以独立实体出现的设备，包括传统的基于端口的设备、主机到外设的总线以及大部分片内集成的控制器等。 这些设备的一个共同点是 CPU 都可以通过总线直接对它们进行访问。 



- platform_device 数据结构

```c
struct platform_device {
  const char * name; /* 设备名称 */
  int id; /* 设备 ID */
  struct device dev; /* 设备的 device 数据结构 */
  u32 num_resources; /* 资源的个数 */
  struct resource * resource; /* 设备的资源 */
  const struct platform_device_id *id_entry; /* 设备 ID 入口 */
  /*体系结构相关的附加项*/
  struct pdev_archdata archdata; /* 体系结构相关的数据 */
};
```

- 分配 platform_device 结构 

```c
struct platform_device *platform_device_alloc(const char *name, int id);
```

- 添加资源 

```c
int platform_device_add_resources(struct platform_device *pdev, const struct resource *res, unsigned int num);
```

​	添加私有数据的函数 

```c
int platform_device_add_data(struct platform_device *pdev, const void *data, size_t size);
```

- 注册和注销 platform_device 

```c
int platform_device_register(struct platform_device *pdev);//注册一个 platform_device
int platform_add_devices(struct platform_device **devs, int num);//注册多个 platform_device

void platform_device_unregister(struct platform_device *pdev);
```

- 获取设备的资源 

```c
struct resource *platform_get_resource(struct platform_device *dev, unsigned int type, unsigned int num);
//dev 指向包含资源定义的 platform_device 结构； 
//type 表示将要获取的资源类型； 
//num 表示获取资源的数量。
//返回值为 0 表示获取失败，成功返回申请的资源地址。 
```



#### 向系统添加平台设备的流程 

1. 定义资源，然后定义 platform_device 结构并初始化；最后注册； 
2. 定义资源，然后动态分配一个 platform_device 结构，接着往结构添加资源
   信息，最后注册。 



### 平台驱动 platform_driver 

```c
struct platform_driver {
  int (*probe)(struct platform_device *); /* probe 方法 */
  int (*remove)(struct platform_device *); /* remove 方法 */
  void (*shutdown)(struct platform_device *); /* shutdown 方法 */
  int (*suspend)(struct platform_device *, pm_message_t state); /* suspend 方法 */
  int (*resume)(struct platform_device *); /* resume 方法 */
  struct device_driver driver; /* 设备驱动 */
  const struct platform_device_id *id_table; /* 设备的 ID 表 */
};
```



注册和注销 platform_driver 

```c
int platform_driver_register(struct platform_driver *drv);
int platform_driver_probe(struct platform_driver *driver, int (*probe)(struct platform_device *));

void platform_driver_unregister(struct platform_driver *drv);
```

注册驱动必须保证 platform_driver 的 driver.name 字段必须和 platform_device 的 name 相同 。



### 平台驱动示例 

led_platform.c  平台驱动

（注册平台设备）

```c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/device.h>
#include <linux/platform_device.h>

#define GPIO_LED_PIN_NUM 55 /* gpio 1_23 */
/* 定义 LED 资源 */
static struct resource led_resources[] = {
  [0] = {
    .start = GPIO_LED_PIN_NUM,
    .end = GPIO_LED_PIN_NUM,
    .flags = IORESOURCE_IO,
  },
};

static void led_platform_release(struct device *dev)
{
  return;
}

/* 定义平台设备 */
static struct platform_device led_platform_device = {
  .name = "led", /* platform_driver 中， .name 必须与该名字相同 */
  .id = -1,
  .num_resources = ARRAY_SIZE(led_resources),
  .resource = led_resources,
  .dev = {
    /* Device 'led' does not have a release() function, it is broken and must be fixed. */
    .release = led_platform_release,
    .platform_data = NULL,
  },
};

static int __init led_platform_init(void)
{
  int ret;

  //注册平台设备
  ret = platform_device_register(&led_platform_device);
  if (ret < 0) {
    platform_device_put(&led_platform_device);
    return ret;
  }

  return 0;
}

static void __exit led_platform_exit(void)
{
  platform_device_unregister(&led_platform_device);
}

module_init(led_platform_init);
module_exit(led_platform_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Chenxibing, linux@zlgmcu.com");
```

led_drv.c  设备驱动

（注册平台驱动）

```c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/version.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/platform_device.h>
#include <asm/gpio.h>

#include "led_drv.h"

static int major;
static int minor;
struct cdev *led; /* cdev 数据结构 */
static dev_t devno; /* 设备编号 */
static struct class *led_class;
static int led_io; /* 用于保存 GPIO 编号 */

#define DEVICE_NAME "led"

static int led_open(struct inode *inode, struct file *file )
{
  try_module_get(THIS_MODULE);
  gpio_direction_output(led_io, 1);
  return 0;
}

static int led_release(struct inode *inode, struct file *file )
{
  module_put(THIS_MODULE);
  gpio_direction_output(led_io, 1);
  return 0;
}

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,36)
int led_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
#else
static int led_ioctl(struct inode *inode, struct file *file, unsigned int cmd, unsigned long arg)
#endif
{
  if (_IOC_TYPE(cmd) != LED_IOC_MAGIC) {
    return -ENOTTY;
  }

  if (_IOC_NR(cmd) > LED_IOCTL_MAXNR) {
    return -ENOTTY;
  }

  switch(cmd) {
    case LED_ON:
      gpio_set_value(led_io, 0);
      break;

    case LED_OFF:
      gpio_set_value(led_io, 1);
      break;

    default:
      gpio_set_value(led_io, 0);
      break;
  }

  return 0;
}

struct file_operations led_fops = {
  .owner = THIS_MODULE,
  .open = led_open,
  .release = led_release,
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,36)
  .unlocked_ioctl = led_ioctl
#else
  .ioctl = led_ioctl
#endif
};

static int __devinit led_probe(struct platform_device *pdev)
{
  int ret;
  struct resource *res_io;
  res_io = platform_get_resource(pdev, IORESOURCE_IO, 0); /* 从设备资源获取 IO 引脚 */
  led_io = res_io->start;

  ret = alloc_chrdev_region(&devno, minor, 1, DEVICE_NAME); /* 从系统获取主设备号 */
  major = MAJOR(devno);
  if (ret < 0) {
    printk(KERN_ERR "cannot get major %d \n", major);
    return -1;
  }

  led = cdev_alloc(); /* 分配 led 结构 */
  if (led != NULL) {
    cdev_init(led, &led_fops); /* 初始化 led 结构 */
    led->owner = THIS_MODULE;
    if (cdev_add(led, devno, 1) != 0) { /* 增加 led 到系统中 */
      printk(KERN_ERR "add cdev error!\n");
      goto error;
    }
  } else {
    printk(KERN_ERR "cdev_alloc error!\n");
    return -1;
  }

  led_class = class_create(THIS_MODULE, DEVICE_NAME"_class");
  if (IS_ERR(led_class)) {
    printk(KERN_INFO "create class error\n");
    return -1;
  }

  device_create(led_class, NULL, devno, NULL, DEVICE_NAME);
  return 0;

  error:
  unregister_chrdev_region(devno, 1); /* 释放已经获得的设备号 */
  return ret;
}

static int __devexit led_remove(struct platform_device *dev)
{
  cdev_del(led); /* 移除字符设备 */
  unregister_chrdev_region(devno, 1); /* 释放设备号 */
  device_destroy(led_class, devno);
  class_destroy(led_class);
  return 0;
}

/* 定义和初始化平台驱动 */
static struct platform_driver led_platform_driver = {
  .probe = led_probe,
  .remove = __devexit_p(led_remove),
  .driver = {
  	.name = "led", /* 该名称必须与 platform_device 的.name 相同 */
  	.owner = THIS_MODULE,
  },
};

static int __init led_init(void)
{
  return(platform_driver_register(&led_platform_driver));//注册平台驱动
}

static void __exit led_exit(void)
{
  platform_driver_unregister(&led_platform_driver);
}

module_init(led_init);
module_exit(led_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Chenxibing, linux@zlgmcu.com");
```



驱动测试 

将两份驱动分别编译得到 led_platform.ko 和 led_drv.ko 两个驱动模块，按顺序依次插入，然后运行测试程序： 

```shell
[root@ M283 mnt]# insmod led_platform.ko
[root@ M283 mnt]# insmod led_drv.ko
[root@ M283 mnt]# ./led_test
```





---

# 第十五章 具体驱动开发



## LED驱动



### LED 子系统的分层结构 

LED 子系统的可以分为三部分：触发器、 LED 设备和核心模块 。

触发器是LED设备显示方式，如heartbeat，none, nand-disk, mmc等.

核心模块的任务 

- 维护 LED 子系统的所有触发器，为触发器的注册/注销提供操作函数；
- 维护 LED 子系统的所有 LED 设备，并为每个 LED 设备在/sys/class/leds/目录下实现操作接口；为 LED 设备的注册/注销提供操作函数。 



### LED 设备的实现 

#### 初始化led_classdev 结构体

LED 子系统的每个 LED 设备都是用 led_classdev 结构体描述，该结构体定义在
<linux/leds.h>文件 。 

```c
struct led_classdev {
  const char *name;//LED 设备的名字
  int brightness;// LED 当前的亮度
  int max_brightness;// LED 的最高亮度值
  int flags;
  void (*brightness_set)(struct led_classdev *led_cdev,
                         enum led_brightness brightness);
  enum led_brightness (*brightness_get)(struct led_classdev *led_cdev);//设置 LED 点亮/熄灭的方法
  int (*blink_set)(struct led_classdev *led_cdev,
                   unsigned long *delay_on,
                   unsigned long *delay_off);
  struct device *dev;
  struct list_head node;
  const char *default_trigger;// LED 设备在注册后， 默认使用的触发器名字。
  struct rw_semaphore trigger_lock;
  struct led_trigger *trigger;
  struct list_head trig_list;
  void *trigger_data;
};
```



#### LED 设备注册

```c
int led_classdev_register(struct device *parent, struct led_classdev *led_cdev);
//parent 可取值为 NULL。 led_classdev_register()函数调用成功后， 将返回 0值； 否则返回非 0 值。
```



#### LED 设备实现示例 

在 leds-test.c 模块文件中，需要为 ERR LED 实现一个 LED 设备 

```c
#define LED_GPIO MXS_PIN_TO_GPIO(PINID_LCD_D23) /* ERR LED 的 GPIO */

struct led_classdev led_dev = {
  .name = "led-example", /* 设备名称为 led-example */
  .brightness_set = mxs_led_brightness_set,
  .default_trigger = "none", /* 默认使用 none 触发器 */
};

//ERR LED 的点亮/熄灭的实现函数为 mxs_led_brightness_set()
static void mxs_led_brightness_set(struct led_classdev *pled, enum led_brightness value)
{
  gpio_direction_output(LED_GPIO, !value);
}

//在模块的初始化函数中，需要为 ERR LED 注册 LED 设备和申请 GPIO 
static int __init led_init(void)
{
  int ret = 0;
  ret = led_classdev_register(NULL, &led_dev); /* 注册 LED 设备 */
  if (ret) {
    printk("register led device faile \n");
    return -1;
  }
  gpio_request(LED_GPIO, "led"); /* 申请 GPIO */
  return 0;
}

//在模块的移除函数中，需要为 ERR LED 注销 LED 设备和释放 GPIO
static void __exit led_exit(void)
{
  led_classdev_unregister(&led_dev); /* 注销 LED 设备 */
  gpio_free(LED_GPIO); /* 释放 GPIO */
}

module_init(led_init);
module_exit(led_exit);
```



把 leds-test.c 模块编译成 leds-test.ko 模块文件， 加载模块 

```shel
# insmod leds-test.ko
```





## GPIO 驱动 

本章讲述在内核的 GPIOLIB框架下实现 GPIO 驱动。 



### GPIOLIB 的内核接口 

GPIOLIB 的内核接口是指：若某些 GPIO 在 GPIOLIB 框架下被驱动后， GPIOLIB 为内
核的其它代码操作该 GPIO 而提供的标准接口 .



#### GPIO 的申请和释放 

GPIO 在使用前，必须先申请 GPIO 

```c
int gpio_request(unsigned gpio, const char *label);
//gpio 参数为 GPIO 编号； label 参数为 GPIO 的标识字符串，可以随意设定。
//调用成功，将返回 0 值；否则返回非 0 值。
```

当 GPIO 使用完成后，应当释放 GPIO

```c
void gpio_free(unsigned gpio);
```

#### GPIO 的输出控制 

设置为输出方向 

```c
int gpio_direction_output(unsigned gpio, int value);
```

控制 GPIO 输出高电平或低电平 

```c
void gpio_set_value(unsigned gpio, int value);
```

#### GPIO 的输入控制 

设置 GPIO 为输入方向 

```c
int gpio_direction_input(unsigned gpio);
```

读取 GPIO 的输入电平状态 

```c
int gpio_get_value(unsigned gpio);
```

#### GPIO 的中断映射 

GPIO 引脚在被设置为输入方向后，可以用于外部中断信号的输入。 通过 GPIO 编号而获得该 GPIO 中断号 .

```c
int gpio_to_irq(unsigned gpio);
//返回 GPIO 中断号
```

并不是所有的 GPIO 都可以作为外部中断信号输入端口 .



### GPIOLIB 的实现方法 

GPIOLIB 对每组 GPIO 都用一个 gpio_chip 对象来实现其驱动。 

```c
struct gpio_chip {
  const char *label;
  struct device *dev;
  struct module *owner;//所有者， 一般设置为 THIS_MODULE。
  int (*request)(struct gpio_chip *chip, unsigned offset);
  void (*free)(struct gpio_chip *chip, unsigned offset);
  int (*direction_input)(struct gpio_chip *chip, unsigned offset);
  int (*get)(struct gpio_chip *chip, unsigned offset);
  int (*direction_output)(struct gpio_chip *chip, unsigned offset, int value);
  int (*set_debounce)(struct gpio_chip *chip, unsigned offset, unsigned debounce);
  void (*set)(struct gpio_chip *chip, unsigned offset, int value);
  int (*to_irq)(struct gpio_chip *chip, unsigned offset);
  void (*dbg_show)(struct seq_file *s, struct gpio_chip *chip);
  int base;//该组 GPIO 的起始值。
  u16 ngpio;//该组 GPIO 的数量
  const char *const *names;
  unsigned can_sleep:1;
  unsigned exported:1;
};
```

当 GPIO 控制器初始化完成后，就可以注册到内核： 

```c
int gpiochip_add(struct gpio_chip *chip);
//调用成功后，将返回 0 值；否则将返回非 0 值。
```

当需要把 GPIO 控制器从内核注销时 

```c
int __must_check gpiochip_remove(struct gpio_chip *chip);
```



### GPIO驱动示例 

```c
//实现该组的 GPIO 控制器 
struct gpio_chip mx28_gpio_chip = {
  .label = "example_gpio",
  .owner = THIS_MODULE,
  .base = 160,
  .ngpio = 2,
  .request = mxs_gpio_request,
  .free = mxs_gpio_free,
  .direction_input = mxs_gpio_input,
  .get = mxs_gpio_get,
  .direction_output = mxs_gpio_output,
  .set = mxs_gpio_set
  .exported = 1,
}

//具体函数实现
static int mxs_gpio_request(struct gpio_chip *chip, unsigned int pin)
{
  void __iomem *addr = PINCTRL_BASE_ADDR;
  pin += 4;
  __raw_writel(0x3 << pin * 2, addr + HW_PINCTRL_MUXSEL6_SET); /* set as GPIO */
  return 0;
}
static int mxs_gpio_input(struct gpio_chip *chip, unsigned int index)
{
  void __iomem *base = PINCTRL_BASE_ADDR;
  index += 4;
  __raw_writel(1 << index, base + HW_PINCTRL_DOE3_CLR);
  return 0;
}
static int mxs_gpio_get(struct gpio_chip *chip, unsigned int index)
{
  unsigned int data;
  void __iomem *base = PINCTRL_BASE_ADDR;
  index += 4;
  data = __raw_readl(base + HW_PINCTRL_DIN3);
  return data & (1 << index);
}
static int mxs_gpio_output(struct gpio_chip *chip, unsigned int index, int v)
{
  void __iomem *base = PINCTRL_BASE_ADDR;
  index += 4;
  __raw_writel(1 << index, base + HW_PINCTRL_DOE3_SET); /* 设置为输出工作模式 */
  if (v) { /* 当 v 为非 0 时， 设置 GPIO 输出高电平 */
    __raw_writel(1 << index, base + HW_PINCTRL_DOUT3_SET);
  } else { /* 当 v 为 0 时，设置 GPIO 输出低电平 */
    __raw_writel(1 << index, base + HW_PINCTRL_DOUT3_CLR);
  }
  return 0;
}
static void mxs_gpio_set(struct gpio_chip *chip, unsigned int index, int v)
{
  void __iomem *base = PINCTRL_BASE_ADDR;
  index += 4;
  if (v) { /* 设置 GPIO 输出高电平 */
    __raw_writel(1 << index, base + HW_PINCTRL_DOUT3_SET);
  } else { /* 设置 GPIO 输出低电平 */
    __raw_writel(1 << index, base + HW_PINCTRL_DOUT3_CLR);
  }
}


//在模块的初始化函数中，需要注册 GPIO 控制器
static int __init mx28_gpio_init(void)
{
  int ret = 0;
  ret = gpiochip_add(&mx28_gpio_chip);
  if (ret) {
    printk("add example gpio faile:%d \n", ret);
    goto out;
  }
  printk("add example gpio success... \n");
  out:
  return ret;
}
//在模块的移除函数中，需要注销 GPIO 控制器
static void __exit mx28_gpio_exit(void)
{
gpiochip_remove(&mx28_gpio_chip);
printk("remove example gpio... \n");
}


module_init(mx28_gpio_init);
module_exit(mx28_gpio_exit);
```



示例驱动测试 

上述的代码模块编译成 mx28_gpio.ko 文件， 输入下面命令加载模块 

```shell
# insmod mx28_gpio.ko
```

命令执行完成后，在/sys/class/gpio/目录可看到新添加的控制器 

进入 gpiochip160 目录，可以看到新添加的 GPIO 控制器的属性文件 

在/sys/class/gpio/export 中，可以导出 160 和 161 的 GPIO 

```shell
# echo 160 >export
# echo 161 >export
```

gpio160 目录包含了 GPIO3_4 的控制属性文件。 

在gpio160 目录下设置 GPIO 为输出工作状态： 

```shell
# echo out >direction
# echo 1 >value
# echo 0 >value
```

​	这时使用万用表可以在 URX1 排针分别测试到 3.3V 和 0V。 



## 按键驱动 

### 输入子系统 

Linux 内核的输入子系统为鼠标、键盘、触摸屏、游戏杆等输入设备提供了驱动框架。
当程序员要为自己的输入设备编写驱动程序时，只需要实现从设备获取输入事件即可。至于输入事件如何处理，用户接口如何实现，都由输入子系统完成。 



输入子系统构成 

- 输入子系统要为每个输入设备都在/dev/目录下生成一个设备文件 
- 对于每一个输入设备，在输入子系统只需要实现其事件获取即可 
- 在 Linux 输入设备的可以分为三类，为这些输入设备而实现的设备文件的接口必须有所差别。
  - 事件类（如 USB 鼠标、 USB 键盘、触摸屏等）、 
  - MOUSE类（特指 PS/2 接口的输入设备）、
  - 游戏杆等类型。 



设备驱动、核心模块、事件管理器构成了输入子系统 



#### 设备驱动 

输入子系统为每个输入设备都实现一个设备驱动 .

Linux 内核源码为一些常用的输入设备提供了驱动源码。这些源码分别在 drivers/input/
目录下的多个子目录下 

| 目录名称        | 目录内容                         |
| ----------- | ---------------------------- |
| joystick    | 游戏杆输入设备驱动源码                  |
| keyboard    | 键盘驱动源码                       |
| mouse       | 鼠标驱动源码                       |
| misc        | 杂类输入设备源码                     |
| serio       | 总线型（如串口、 SPI、 I2C 等总线）输入设备源码 |
| touchscreen | 触摸屏驱动源码                      |

#### 事件管理器 

输入子系统为每种输入设备类型都实现一个事件管理器。事件管理器管理自己类型下的所有输入设备的设备驱动。每个事件管理器都可以动态注册到输入子系统，或从输入子系统中注销。 

内核源码为事件类、 MOUSE 类、游戏杆类 这三种类型的输入设备分别实现了 evdev、 mousedev、 joydev 事件管理器。 

当一个设备驱动被注册到输入子系统后，每个事件管理器都扫描这个设备驱动的身份信息，并用自身携带的输入设备匹配列表和设备驱动的身份进行比较，以确定该设备驱动是否和自己匹配。若事件管理器检测到和自己匹配的设备驱动，会为该设备驱动在生成设备文件 

![](https://note.youdao.com/yws/public/resource/ea43181f60c17fcc4449163ab62b9e2c/xmlnote/WEBRESOURCEaaaf4431bc80f01a226622c4c6a79826/9748)

事件管理器的携带了一个 file_operation 类型的文件操作列表。新生成的设备文件的文
件 I/O 实现就是由这个文件操作列表实现。该文件操作列表为设备文件实现了 open、 close、read、 ioctl、 sync 等调用。 

#### 核心模块 

输入子系统使用了核心模块管理了所有注册的设备驱动和事件管理器。同时核心模块为
设备驱动和事件管理器提供了注册/注销函数。另外事件管理器和设备驱动之间沟通，也由
核心模块提供桥梁。 

![](https://note.youdao.com/yws/public/resource/ea43181f60c17fcc4449163ab62b9e2c/xmlnote/WEBRESOURCEefca837b07b9739e0206f00850e21586/9750)



### 输入设备驱动 

每个设备驱动都是由 input_dev 的数据结构描述 

```c
struct input_dev {
  const char *name;//设备驱动的名字
  const char *phys;
  const char *uniq;
  struct input_id id;//输入设备的身份,描述了输入设备的总线类型、厂商号、产品号、版本的信息。
  unsigned long evbit[BITS_TO_LONGS(EV_CNT)];//输入设备的会产生的输入事件类型。
  unsigned long keybit[BITS_TO_LONGS(KEY_CNT)];
  unsigned long relbit[BITS_TO_LONGS(REL_CNT)];
  unsigned long absbit[BITS_TO_LONGS(ABS_CNT)];
  unsigned long mscbit[BITS_TO_LONGS(MSC_CNT)];
  unsigned long ledbit[BITS_TO_LONGS(LED_CNT)];
  unsigned long sndbit[BITS_TO_LONGS(SND_CNT)];
  unsigned long ffbit[BITS_TO_LONGS(FF_CNT)];
  unsigned long swbit[BITS_TO_LONGS(SW_CNT)];
  unsigned int keycodemax;
  unsigned int keycodesize;
  void *keycode;
  int (*setkeycode)(struct input_dev *dev, unsigned int scancode, unsigned 	 int keycode);
  int (*getkeycode)(struct input_dev *dev, unsigned int scancode, unsigned   int *keycode);
  struct ff_device *ff;
  unsigned int repeat_key;
  struct timer_list timer;
  „„省略„„
};
```

#### 注册/注销设备驱动 

```c
int input_register_device(struct input_dev *);

void input_unregister_device(struct input_dev *);
```

#### 输入事件的提交 

- 提交任何类型的事件 

  当设备驱动检测到输入事件发生后，把输入事件向子系统报告 

```c
void input_event(struct input_dev *dev, unsigned int type, unsigned int code, int value);
```

- 提交按键事件 

```c
void input_report_key(struct input_dev *dev, unsigned int code, int value);
//input_report_key(dev, KEY_A, 1);
```

- 提交绝对坐标事件 

```c
void input_report_abs(struct input_dev *dev, unsigned int code, int value);
//input_report_abs(dev, ABS_X, value);
```

- 提交相对坐标事件 

```c
void input_report_rel(struct input_dev *dev, unsigned int code, int value);
//input_report_rel(dev, REL_X, 1); /* 报告 X 轴坐标值增加 */
//input_report_rel(dev, REL_X, -1); /* 报告 X 轴坐标值减小 */
```

- 提交同步事件 

```c
void input_sync(struct input_dev *dev);
```



### 按键驱动实现 

#### 按键驱动的设计思路

对于按键驱动需要实现以下目的：
(1) 当每一个按键被按下后，能准确提交键按下事件；
(2) 当按键被提起后，能准确提交键提起事件；
(3) KEY1、 KEY2、 KEY3、 KEY4、 KEY5 键分别能产生 A、 B、 C、 D、 E 键值。

为实现以上目的，按键驱动的实现方法为：
(1) 为按键驱动实现并初始化一个 input_dev 结构体，然后注册；
(2) 为每一个按键对应的中断都注册一个中断处理函数；
(3) 当某一个按键被按下时，其对应的中断处理函数执行；
(4) 在中断处理函数中，对按键作消抖处理，然后提交相应的键按下事件；
(5) 提交了键按下事件后，中断处理提交工作队列；
(6) 当工作队列的工作函数被执行时， 一直等待到按键被提起，然后提交按键的提起事
件。 



imx28x_key .c

```c
//为方便描述某个按键的信息而定义了 imx28x_key_struct 结构
struct imx28x_key_struct {
  int key_code; /* 按键能产生的键值*/
  int gpio; /* 按键连接的 GPIO */
  struct work_struct work; /* 按键的工作队列 */
};

struct imx28x_key_struct keys_list[] ={
  {.key_code = KEY_A, .gpio = MXS_PIN_TO_GPIO(PINID_LCD_D17)},
  {.key_code = KEY_B, .gpio = MXS_PIN_TO_GPIO(PINID_LCD_D18)},
  {.key_code = KEY_C, .gpio = MXS_PIN_TO_GPIO(PINID_SSP0_DATA4)},
  {.key_code = KEY_D, .gpio = MXS_PIN_TO_GPIO(PINID_SSP0_DATA5)},
  {.key_code = KEY_E, .gpio = MXS_PIN_TO_GPIO(PINID_SSP0_DATA6)}
};


//中断函数
static irqreturn_t imx28x_key_intnerrupt(int irq, void *dev_id, struct pt_regs *regs)
{
  int i = (int)dev_id;
  int gpio = keys_list[i].gpio; /* 获取按键的 GPIO */
  int code = keys_list[i].key_code; /* 获取按键的键值 */
  /*
* 延迟 20uS，看按键是不是按下，如果不是，就是抖动
*/
  udelay(20);
  if (gpio_get_value(gpio)) {
    return IRQ_HANDLED;
  }
  input_report_key(inputdev, code, 1); /* 先报告键按下事件 */
  input_sync(inputdev);
  schedule_work(&(keys_list[i].work)); /* 提交工作队列，实现中断的下半部处理 */
  return IRQ_HANDLED;
}
//当工作队列被执行时，工作函数 imx28x_scankeypad()将被调用
static void imx28x_scankeypad(struct work_struct *_work)
{
  /* 通过工作队列指针而获得它所属的 imx28x_key_struct 类型的对象 */
  struct imx28x_key_struct *key_tmp = container_of(_work, struct imx28x_key_struct, work);
  int gpio = key_tmp->gpio;
  int code = key_tmp->key_code;
  /* 每隔 10mS 检查按键是否已经提起， 如果没有提起就一直等待 */
  while(!gpio_get_value(gpio)){
    mdelay(10);
  }
  input_report_key(inputdev, code, 0); /* 报告按键提起事件 */
  input_sync(inputdev);
}



static int __devinit iMX28x_key_init(void)
{
  int i = 0, ret = 0;
  int irq_no = 0;
  int code, gpio;
  inputdev = input_allocate_device(); /* 为输入设备驱动对象申请内存空间*/
  if (!inputdev) {
    return -ENOMEM;
  }
  inputdev->name = "EasyARM-i.MX28x_key";
  set_bit(EV_KEY, inputdev->evbit); /* 设置输入设备支持按键事件 */
  for (i = 0; i < sizeof(keys_list)/sizeof(keys_list[0]); i++) 
  {
    code = keys_list[i].key_code;
    gpio = keys_list[i].gpio;
    /* 为每个按键都初始化工作队列 */
    INIT_WORK(&(keys_list[i].work), imx28x_scankeypad);
    set_bit(code, inputdev->keybit); /* 设置输入设备支持的键值 */
    /* 为每个按键都初始化 GPIO */
    gpio_free(gpio);
    ret = gpio_request(gpio, "key_gpio");
    if (ret) {
      printk("request gpio failed %d \n", gpio);
      return -EBUSY;
    }
    /* 当 GPIO 被设置为输入工作状态后，就可以检测中断信号 */
    gpio_direction_input(gpio);
    /* 把每个 GPIO 中断响应方式都设置为下降沿响应 */
    irq_no = gpio_to_irq(gpio);
    set_irq_type(gpio, IRQF_TRIGGER_FALLING);
    /* 为每个按键的中断都安装中断处理函数，其私有数据为按键信息在 keys_list 数组下的索引 */
    ret = request_irq(irq_no, imx28x_key_intnerrupt, IRQF_DISABLED, "imx28x_key", (void *)i);
    if (ret) {
      printk("request irq faile %d!\n", irq_no);
      return -EBUSY;
    }
  }
  input_register_device(inputdev); /* 注册设备驱动 */
  printk("EasyARM-i.MX28x key driver up \n");
  return 0;
}

static void __exit iMX28x_key_exit(void)
{
  int i = 0;
  int irq_no;
  for (i = 0; i < sizeof(keys_list)/sizeof(keys_list[0]); i++) {
    irq_no = gpio_to_irq(keys_list[i].gpio); /* 为每个按键释放 GPIO */
    free_irq(irq_no, (void *)i); /* 为每个按键卸载中断处理函数 */
  }
  input_unregister_device(inputdev); /* 注销输入设备驱动 */
  printk("EasyARM-i.MX28x key driver remove \n");
}

module_init(iMX28x_key_init);
module_exit(iMX28x_key_exit);
```



驱动测试 

把上述驱动代码模块编译成 imx28x_key.ko 驱动文件 , 然后加载驱动 

```shell
root@EasyARM-iMX283 ~# insmod imx28x_key.ko
```

驱动模块加载完成后， 将在/dev/input 目录生成设备文件 , 生成的设备文件为/dev/input/event1 .





---



# 第十六章 嵌入式 Linux Bootloader 

运行嵌入式 Linux 的系统，一般都由引导程序bootloader、内核kernel以及根文件系统system等几部分组成，一般都存放在 Flash 闪存这样的存储介质上 。



通过J-Link下载Bootloader到开发板，开机进入Bootloader，再通过tftp把内核下载到特定地址，最后设置和修改内核参数（环境变量），就可以开机运行内核。



## Bootloader 简介 

嵌入式 Linux 的 Bootloader 有很多，例如 U-Boot、Vivi、Blob 等 。

### Bootloader 的功能 

- 引导
  - Bootloader 的基本功能是引导嵌入式 Linux 运行，通常是先将 Linux 内核加载在RAM指定位置，设置内核启动参数，然后启动 Linux。 
- 下载 
  - Bootloader 的功能还包括固化和更新内核，甚至更新 Bootloader 本身和 Linux 文件系统等，有的 Bootloader 还有硬件测试功能。 



## U-Boot 

全称 Universal Boot Loader 

### U-Boot 的特点 

- 开放源码，自由使用；
- 支持多种嵌入式操作系统内核，如 Linux、 NetBSD、 VxWorks、 QNX、 RTEMS 等；
- 支持多个处理器系列，如 PowerPC、 ARM、 x86、 MIPS、 XScale；
- 可靠性和稳定性都较好；
- 支持命令行，有自己的 Shell；
- 配置灵活，使用方便；
- 支持外设丰富，如串口、以太网、 SDRAM、 FLASH、 LCD、 NVRAM、 EEPROM、RTC、键盘等；
- 文档较多，网络技术支持方便。 

### U-Boot 的功能 

- 系统引导；
- 支持 NFS 挂载、 RAMDISK（压缩或非压缩）形式的根文件系统；
- 支持 NFS 挂载、从 FLASH 中引导压缩或非压缩系统内核；
- 操作系统接口功能强大：可灵活设置、传递多个关键参数给操作系统，适合系统在不同开发阶段的调试要求与产品发布；
- CRC32 校验，可校验 FLASH 中内核、 RAMDISK 镜像文件是否完好；
- 提供各种外设的驱动，如串口、 FLASH、以太网、 LCD、 EEPROM、键盘、 USB、PCMCIA、 RTC 等；
- 上电自检能：可自动检测 SDRAM、 FLASH 大小，也能检测外设故障；
- 特殊功能：还可支持 XIP 内核引导。 

### U-Boot 使用 

#### U-Boot常用命令

- 进入命令 

  - U-Boot 自带命令行接口，在 U-Boot 启动期间，按空格可进入 U-Boot Shell 命令行 查看命令列表 

- 查看命令列表 

  - 输入?或者 help 可以查看 U-Boot 所支持的全部命令以及介绍。 

  - ```shell
    MX28 U-Boot > ?
    ? - alias for 'help'
    base - print or set address offset
    bdinfo - print Board Info structure
    bootm - boot application image from memory
    bootp - boot image via network using BOOTP/TFTP protocol
    chpart - change active partition
    cmp - memory compare
    cp - memory copy
    crc32 - checksum calculation
    dhcp - boot image via network using DHCP/TFTP protocol
    echo - echo args to console
    go - start application at address 'addr'
    help - print command description/usage
    i2c - I2C sub-system
    loadb - load binary file over serial line (kermit mode)
    loads - load S-Record file over serial line
    loady - load binary file over serial line (ymodem mode)
    loop - infinite loop on address range
    md - memory display
    mm - memory modify (auto-incrementing address)
    mtdparts - define flash/nand partitions
    mtest - simple RAM read/write test
    mw - memory write (fill)
    nand - NAND sub-system
    nboot - boot from NAND device
    nm - memory modify (constant address)
    ping - send ICMP ECHO_REQUEST to network host
    printenv - print environment variables
    rarpboot - boot image via network using RARP/TFTP protocol
    reset - Perform RESET of the CPU
    run - run commands in an environment variable
    saveenv - save environment variables to persistent storage
    saves - save S-Record file over serial line
    setenv - set environment variables
    tftpboot - boot image via network using TFTP protocol
    ubi - ubi commands
    ubifsload - load file from an UBIFS filesystem
    ubifsls - list files in a directory
    ubifsmount- mount UBIFS volume
    version - print monitor version
    ```

- 启动命令 

  - bootm 命令可以执行内存中的执行的二进代码。而这些二进代码是有特定的格式，通常为 mkimage 命令处理过的文件。  

  ```shell
  MX28 U-Boot > bootm [loadaddr]
  $ bootm C0008000 
  ```

- 组合命令

  - 用；号隔开即可叠加命令

  ```shell
  upkernel=tftp $(loadaddr) $(bootfile);nand erase clean $(kerneladdr) $(filesize);nand write.jffs2 $(loadaddr) $(kerneladdr) $(filesize);setenv kernelsize $(filesize); saveenv
  ```

  ​

#### 环境变量 

- 查看环境变量 

  使用 printenv 命令即可查看 U-boot 的所有环境变量 .

  ```shell
  MX28 U-Boot > printenv

  MX28 U-Boot > printenv serverip
  serverip=192.168.1.94
  ```

- 环境变量的使用 

  使用$()来调用

  ```shell
  $(serverip)

  MX28 U-Boot > ping $(serverip)
  ```

- 设置环境变量 

  使用 setenv 命令可以设置环境变量。 

  ```shell
  MX28 U-Boot > setenv 环境变量名 环境变量值

  MX28 U-Boot > setenv serverip 192.168.1.94
  ```

  保存所设置的环境变量 

  ```shell
  MX28 U-Boot > saveenv
  ```

- 特殊环境变量 

| 环境变量      | 说明                                       |
| --------- | ---------------------------------------- |
| bootdelay | U-boot 启动后会等待延迟若干秒，等待用户按键进入 U-boot 的命令行。至于等待的秒数则由 bootdelay 环境变量设定。 |
| bootcmd   | U-boot 启动后，若没有进入命令行，则自动执行 bootcmd 环境变量保存的命令组合，以启动内核。 |
| bootargs  | 该环境变量保存了内核启动时，传递内核的启动参数。                 |

#### 使用tftp网络 

- 设置网络参数 

  本地 IP 和tftp服务器 IP  

  ```shell
  MX28 U-Boot > setenv ipaddr 192.168.1.89
  MX28 U-Boot > setenv serverip 192.168.1.94
  ```

- ping 命令 

  ping 命令用于探测网络上畅通以及网络上是否有指定 IP 的主机。  

  ```shell
  MX28 U-Boot > ping 192.168.1.94
  ```

- 通过 tftp 下载文件 

  使用 tftp 命令可以把 tftp 服务器的文件下载到内存的指定位置。 

  ```shell
  MX28 U-Boot > tftp loadAddress xxx.xxx.xxx:filename

  MX28 U-Boot > tftp 0x4160000 192.168.1.94:uImage
  ```

  ​

#### NAND Flash 操作 

- NAND Flash 分区 

U-boot 也像内核一样把 NAND Flash 分为若干个分区，以便于管理操作。 NAND Flash分区操作命令为 mtdpart。 



从默认分区表（在 U-boot 源码中设定的）中初始化分区表： 

```shell
MX28 U-Boot > mtdpart default
```

查看分区表 

```shell
MX28 U-Boot > mtdpart
device nand0 <nandflash0>, # parts = 7
#: name size offset mask_flags
0: bootloder 0x00c00000 0x00000000 0
1: reserve 0x00080000 0x00c00000 0
2: reserve 0x00080000 0x00c80000 0
3: bmp 0x00200000 0x00d00000 0
4: reserve 0x00080000 0x00f00000 0
5: rootfs 0x04000000 0x00f80000 0
6: opt 0x03080000 0x04f80000 0
active partition: nand0,0 - (bootloder) 0x00c00000 @ 0x00000000
defaults:
mtdids : nand0=nandflash0
mtdparts:
mtdparts=nandflash0:12m(bootloder),512k(reserve),512k(reserve),2m(bmp),512k(reserve),64m(rootfs),-(opt)
```

- NAND Flash 擦除操作 

```shell
MX28 U-Boot > nand erase part

MX28 U-Boot > nand erase kernel
```

- NAND Flash 写入操作 

```shell
U-Boot $ nand write loadaddr part/offset_addr size
#第一个参数 loadaddr 为内存的起始地址
#每二个参数可以 part 或 offset_addr，part 是写入 NAND Flash 分区名字， offset_addr 是要写入 NAND Flash 的起始地址；
#第三个参数为 size，要写入数据的长度。

MX28 U-Boot > nand write 0x41600000 kernel 0x300000
```

- NAND Flash 读取操作 

```shell
MX28 U-Boot > nand read loadaddr part/ offset_addr size
#第一个参数 loadaddr 为内存的起始地址
#每二个参数可以 part 或 offset_addr，part 是写入 NAND Flash 分区名字， offset_addr 是要写入 NAND Flash 的起始地址；
#第三个参数为 size，要读出数据的长度。

MX28 U-Boot > nand read 0x41600000 kernel 0x300000
```

- NAND Flash 格式化操作 

```shell
MX28 U-Boot > nand scrub
```



### U-Boot 源码介绍 

| 目 录     | 说 明                                      |
| ------- | ---------------------------------------- |
| board   | 存放了 U-Boot 所支持的开发板的相关代码，目前支持几十个不同体系架构的开发板，如 evb4510、 pxa255_idp、 omap2420h4 等 |
| common  | U-Boot 命令实现代码目录                          |
| cpu     | 包含了不同处理器相关的代码，按照不同的处理器进行分类，如 arm920t、 arm926ejs、i386、 nios2 等 |
| drivers | U-Boot 所支持外设的驱动程序。按照不同类型驱动进行分类如 spi、 mtd、 net 等等 |
| fs      | U-Boot 所支持的文件系统的代码。目前 U-Boot 支持 cramfs、 ext2、 fat、 fdos、 jffs2、reiserfs |
| include | U-Boot 头文件目录，里面还包含各种不同处理器的相关头文件等，以 asm-体系架构这样的目录出现。另外，不同开发板的配置文件也在这个目录下： include/configs/ 开发板.h |
| lib_xxx | 不同体系架构的一些库文件目录                           |
| net     | U-Boot 所支持网络协议相关代码，如 bootp、 nfs 等        |
| tools   | U-Boot 工具源代码目录。其中的一些小工具如 mkimage 就非常实用   |

#### U-Boot 启动过程

U-Boot 的启动可以分为第一个阶段和第二个阶段。 

- 第一个阶段

  第一阶段的代码主要用汇编语言写成，主要工作是初始化部分硬件（初始化内存、调试串口等）、搬移代码（从非易失储存器卡中把 U-boot 复制到 SDRAM）、准备 C 代码的执行环境；

  - 当U-Boot 安装在 Nor Flash 
    - 当处理器上电复位后，就在 Nor Flash 的 0 地址执行 U-boot 的第一阶段代码。在该段代码中，需要以__armboot_boot 地址（start_armboot()函数的起始地址）为起始，以 U-Boot 固件大小为长度，把 Nor Flash 上 U-Boot 第二阶段的代码复制到 RAM 的指定地址。 
  - U-Boot 安装在 NAND Flash 
    - 如果 U-boot 安装在 NAND Flash 的首地址，并且处理器设置为 NAND Flash 方式启动（处理器的指定引脚输入高/低电平），那么当处理器上电复位后，将在 NAND Flash 的首地址把U-Boot 前面的一段代码（大小一般为 4K）复制到 RAM 的指定地址，然后执行这段代码。U-Boot 的第一阶段代码因此被执行。在该段代码中，会初始化 NAND Flash 控制器然后把整个 U-Boot 代码（自然包含了第二阶段代码）复制到 RAM 的指定地址。 

- 第二阶段 

  - 第二阶段代码主要用 C 语言写成，主要任务是初始化硬件、环境变量、部份驱动等，最后进入命令提示符。 
  - 当第一阶段启动完成后，就会启动 start_armboot()函数，进入第二阶段的启动。 
  - ![](https://note.youdao.com/yws/public/resource/ea43181f60c17fcc4449163ab62b9e2c/xmlnote/WEBRESOURCE580d759341da52b13b38b6091180646d/9752)



#### U-Boot 的配置文件 

所有开发板的配置文件都在<include/configs/>目录下，其中该目录下的 mx28_evk.h 文件就是EPC-28x 的配置文件。 

- 定义 U-Boot 的命令行提示符 

```c
#define CONFIG_SYS_PROMPT "MX28 U-Boot > "
```

- bootdelay 环境变量的默认值 

```c
#define CONFIG_BOOTDELAY 0
```

- bootcmd 环境变量的默认值 

```c
#define CONFIG_BOOTCOMMAND "run nand_boot"
//若不进入 U-Boot 命令行终端， 将默认执行“run nand_boot” 
```

- U-Boot 固件的大小 

在 U-Boot 启动的第一阶段会把 U-Boot 的第二阶段代码复制到 RAM 里面. 

```c
#define UBOOT_IMAGE_SIZE 0x50000
//该设置表示 U-Boot 的固件大小为 320K。
```

- 设置 NAND Flash 的默认分区表 

```c
#define MTDPARTS_DEFAULT "mtdparts=nandflash0:12m(bootloder)," \
"512k(reserve)," \
"512k(reserve)," \
"2m(bmp)," \
"512k(reserve)," \
"64m(rootfs)," \
"-(opt)"
```

| 分区   | 大小    | 用途                        |
| ---- | ----- | ------------------------- |
| mtd0 | 12MB  | Linux 内核 1 & Linux 内核（备份） |
| mtd1 | 512KB | U-Boot                    |
| mtd2 | 512KB | 保留分区                      |
| mtd3 | 2MB   | 启动画面                      |
| mtd4 | 512KB | 保留分区                      |
| mtd5 | 64MB  | 用户文件系统区域                  |
| mtd6 | 剩余空间  | /opt 分区，可存放用户数据或者程序       |

- 设置自定义的默认环境变量 

```c
#define CONFIG_EXTRA_ENV_SETTINGS \
"kernel=uImage\0" \
"kernelsize=0x300000\0" \
"rootfs=rootfs.ubifs\0" \
"showbitmap=0\0" \
"kerneladdr=" "0x00200000\0" \
"kerneladdr2=" "0x00700000\0" \
省略„„
```



#### U-Boot Tools 

mkimage 工具，在编译内核的时候需要用到，务必复制到系统/usr/bin 目录下 .




### U-Boot 编译实例 

把光盘资料中的 bootloader.tar.bz2 文件复制到 Linux 主机的工作目录，然后解压该压缩包, 包含有 3 个目录 elftosb、 u-boot-2009.08 和imx-bootlets-src-10.12.01 

```shell
$ tar -jxvf bootloader.tar.bz2
```

- u-boot-2009.08 目录内有 U-Boot 的源代码。把 U-Boot 源码编译后得到 u-boot 文件；
- imx-bootlets-src-10.12.01 目录包含将 u-boot 文件进一步编译成imx28_ivt_uboot.sb文件（用于烧写到 NAND flash 的文件） 的工具；


-  elftosb 目录下提供了 32bit 和 64bit Linux 系统下适用的 elftosb 转换工具。 



操作步骤

- 进入 u-boot-2009.08 目录，清除原有的编译文件 

```shell
$ cd bootloader/u-boot-2009.08
$ make ARCH=arm CROSS_COMPILE=arm-fsl-linux-gnueabi- distclean
```

- 配置 U-Boot 的平台为 mx28_evk_config 

```shell
$ make ARCH=arm CROSS_COMPILE=arm-fsl-linux-gnueabi- mx28_evk_config
```

- 执行编译 

```shell
$ make ARCH=arm CROSS_COMPILE=arm-fsl-linux-gnueabi-
```

编译完成后将在 u-boot-2009.08 目录的根目录下得到 u-boot 文件。 

- 编译成带电源配置的 imx28_ivt_uboot.sb 固件文件。 

```shell
$ cd ../elftosb/
$ mv elftosb_64bit elftosb # 若用户的 Linux 上位机系统是 32bit 的， 则选择 elftosb_32bit 文件|
$ sudo cp elftosb /usr/bin/
$ sudo chmod 777 /usr/bin/elftosb

$ cp u-boot ../ imx-bootlets-src-10.12.01
$ cd ../ imx-bootlets-src-10.12.01
$ ./ build
```





---

# 第十七章 嵌入式 Linux 文件系统 

根文件系统就是内核启动时挂载的**第一个**文件系统。



一个典型的嵌入式 Linux 根文件系统根目录 

| 目录   | 内容                               | 说明   |
| ---- | -------------------------------- | ---- |
| bin  | 系统命令和工具                          |      |
| dev  | 系统设备文件                           |      |
| etc  | 系统初始化脚本和配置文件                     |      |
| lib  | 系统运行库文件                          |      |
| proc | proc 文件系统                        |      |
| sbin | 系统管理员命令和工具                       |      |
| sys  | sysfs 文件系统                       |      |
| tmp  | 临时文件                             |      |
| usr  | 用户命令和工具，下分 usr/bin 和 usr/sbin 目录 |      |
| var  | 系统运行产生的可变数据                      |      |

要构建一个可用的 Linux 根文件系统， 推荐参考其它现有可用的文件系统，在原有基础上按需修改；或者使用文件系统制作工具如 BusyBox 来实现文件系统的生成。 



## 根文件系统类型 

常见的可用于根文件系统的文件系统类型有 ramdisk、 cramfs、 jffs2、 yaffs/yaffs2 和 ubifs等 

| 类型              | 介质         | 是否压缩 | 是否可写 | 掉电保存 | 存在于 RAM 中 |
| --------------- | ---------- | ---- | ---- | ---- | --------- |
| Ramdisk 上的 EXT2 |            | 是    | 是    | 否    | 是         |
| cramfs          |            | 是    | 否    | -    | 否         |
| jffs2           | NOR Flash  | 是    | 是    | 是    | 否         |
| yaffs/yaffs2    | NAND Flash | 否    | 是    | 是    | 否         |
| ubifs           | NAND Flash | 是    | 是    | 是    | 否         |

- JFFS/JFFS2 

  Journalling Flash File System（闪存设备日志型文件系统， JFFS）  ，JFFS2 是 JFFS 的后继者，由 Red Hat 重新改写而成 。

- YAFFS/YAFFS2 

  YAFFS（Yet Another Flash File System）  ，在 GPL 协议下发布的、基于日志的、专门为 NAND Flash 存储器设计的、适用于大容量的存储设备的嵌入式文件系统 。

- UBIFS 

  UBIFS 文件系统(Unsorted Block Image File System，UBIFS)是用于固态硬盘存储设备上 

除了基于RAM和Flash的文件系统，还有基于NFS的文件系统，多用于测试。

![](https://note.youdao.com/yws/public/resource/ea43181f60c17fcc4449163ab62b9e2c/xmlnote/WEBRESOURCE61cd4efd0e2c4ee31f81aaee5a5e8545/9754)



## BusyBox 制作根文件系统 

Busybox 被誉为 Linux 工具里的“瑞士军刀” ，是一个 Linux 工具集，通过一个可执行文件实现了很多标准 Linux 的命令和工具。 



### 制作过程

#### 下载和解压源码 

Busybox 的源码可从官方主页 www.busybox.net 获得 ，再解压

```shell
chenxibing@linux-compiler: ~$ tar xjvf busybox-1.22.1.tar.bz2
```

#### 修改顶层 Makefile 

进入 busybox-1.22.1 目录， 打开顶层目录下的 Makefile 文件 

```shell
chenxibing@linux-compiler: ~$ cd busybox-1.22.1/
chenxibing@linux-compiler: busybox-1.22.1$ vi Makefile
```

- 修改体系结构 ARCH 的值， 指定体系结构为 arm 

  ```c
  190 ARCH ?= $(SUBARCH)
  修改为
  190 ARCH ?= arm  
  ```

- 修改 CROSS_COMPILE 变量， 指定所使用的交叉编译器 

  ```c
  164 CROSS_COMPILE ?= arm-none-linux-gnueabi-
  ```

如果不修改 Makefile 文件， 也可以在 make 的时候指定 ARCH 和 CROSS_COMPILE 的值 

```shell
chenxibing@linux-compiler: busybox-1.22.1$ make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi-
```

#### 配置 Busybox 

进入 busybox-1.22.1 目录, 输入 make menuconfig 命令，可进入 Busybox 的配置界面 

```shell
chenxibing@linux-compiler: busybox-1.22.1$ make menuconfig
```

- 进入 Busybox Settings-> Build Options 
  - 如果不选中“Build BusyBox as a static binary”则采用动态链接（默认）； 
  - “Cross Compilerprefix” 用于设置编译所用的交叉编译器， 如果已经修改了 Makefile， 这里可以不填。 
- Busybox Settings-> Installation Options  
  - 选中“Don't use /usr”, 避免busybox被安装到宿主系统，破坏宿主系统
  - “BusyBox installation prefix”：指定文件系统的安装路目录 
    - 建议设置为 NFS 共享目录下的一个子目录，如“/home/chenxibing/nfs/myrootfs” 
- 配置完毕，选择“Save Configuration to an Alternate File”，保存配置为一个配置文件如myconfig，默认为.config 文件。 

#### 编译和安装 

输入 make 命令，开始编译 

```shell
chenxibing@linux-compiler: busybox-1.22.1$ make
```

编译完成后，输入 make install 命令完成安装 

```shell
chenxibing@linux-compiler: busybox-1.22.1$ make install
```

安装后，可在安装目录看到 bin、 sbin、 usr 这 3 个目录和一个指向 busybox 可执行文件的软链接 linuxrc 

```shell
chenxibing@linux-compiler: busybox-1.22.1$ ls /home/chenxibing/nfs/myrootfs/
bin linuxrc sbin usr
```

#### 完善目录结构 

BusyBox 安装后，仅仅有 bin、 sbin、 usr 这 3 个目录和软链接 linuxrc，这是不足以构成一个可用的根文件系统 , 需要新建dev etc lib proc sys tmp var 目录

```shell
chenxibing@linux-compiler: ~$ cd /home/chenxibing/nfs/myrootfs/
chenxibing@linux-compiler: myrootfs$ mkdir dev etc lib proc sys tmp var
```

#### 添加 C 运行库 

C 运行库可直接从交叉工具链获取，一般在工具链的“libc/lib/”目录下。 复制到 myrootfs
的“/lib”目录 .

```shell
chenxibing@linux-compiler:myrootfs$ cp -av /home/ctools/arm-2011.03/arm-none-linux-gnueabi/libc/lib/* lib/
```

#### 添加初始化配置脚本 

在“/etc”目录下添加系统启动所需的初始化配置脚本 , 将BusyBox 提供的配置文件复制到 myrootfs 的“/etc”目录 。

```shell
chenxibing@linux-compiler: myrootfs$ cp -av ~/busybox-1.22.1/examples/bootfloppy/etc/* etc/
```

打开 myrootfs/ect/inittab 文件， 注释其中的第 3 行“tty2::askfirst:-/bin/sh”： 

```shell
1 ::sysinit:/etc/init.d/rcS
2 ::respawn:-/bin/sh
3 #tty2::askfirst:-/bin/sh
4 ::ctrlaltdel:/bin/umount -a –r
```



至此，得到了一个可用的基本文件系统 myrootfs 。



## 制作根文件系统镜像

将根文件系统制作成yaffs/yaffs2、Initramfs、NFS等格式的镜像文件，然后在linux内核中配置支持并加入该根文件系统。



### 制作yaffs/yaffs2格式镜像

使用以下工具制作

- yaffs制作工具：mkyaffsimage
- yaffs2制作工具: mkyaffs2image（适合64M）、mkyaffs2image-128（适合128M以上）

```shell
$ cd myrootfs的上一级目录
$ ./mkyaffs2image-128M myrootfs/ myrootfs.yaffs2
```



### 制作 ubifs 镜像文件 

制作 ubifs 镜像文件， 需要知道几个关键参数， 如逻辑擦除块 LEB 大小、 NAND FLASH
页面大小，以及 UBI 分区的物理擦除块数目， 这些信息可在 uboot 命令行输入指令查看 

```shell
MX28 U-Boot > mtdparts default
MX28 U-Boot > ubi part rootfs

Creating 1 MTD partitions on "nand0":
0xf8000041059828-0x4f8000000000000 : "<NULL>"
UBI: attaching mtd1 to ubi0
UBI: physical eraseblock size: 131072 bytes (128 KiB)
UBI: logical eraseblock size: 126976 bytes
UBI: smallest flash I/O unit: 2048
UBI: VID header offset: 2048 (aligned 2048)
UBI: data offset: 4096
UBI: attached mtd1 to ubi0
UBI: MTD device name: "mtd=5"
UBI: MTD device size: 274877906944 MiB
UBI: number of good PEBs: 512
UBI: number of bad PEBs: 0
UBI: max. allowed volumes: 128
UBI: wear-leveling threshold: 4096
UBI: number of internal volumes: 1
UBI: number of user volumes: 1
UBI: available PEBs: 14
UBI: total number of reserved PEBs: 498
UBI: number of PEBs reserved for bad PEB handling: 5
UBI: max/mean erase counter: 2/1
```

由uboot分区信息可知，这是一个在页面大小为 2K 字节，块大小为 128K 字节的 NAND FLASH 上创建了一个64M 字节大小 UBI 分区后得到的信息 。



获得制作 ubifs 镜像所需要的 3 个关键参数： 

- 逻辑擦除块 LEB 大小——126976， 即0x1F000
- 物理擦除块 PEB 数目——512
- NAND 页面大小——2048， 即0x800 

使用mkfs.ubifs 命令制作ubifs 镜像 

```shell
chenxibing@linux-compiler: nfs$ sudo mkfs.ubifs -d myrootfs -e 0x1f000 -c 512 -m 0x800 -x lzo -o rootfs.ubifs
#“-d”指定根文件系统目录
#“-x lzo”表示用 LZO 压缩算法，这是 ubifs 的默认压缩算法
```











































































































































































