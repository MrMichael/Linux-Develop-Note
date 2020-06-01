[TOC]

## 一、Linux 内核源码 

到 www.kernel.org 下载官方内内核。  

### 1.linux内核目录

```shell
$ tree kernel/ -L 1
kernel/
├── android
├── arch
├── backported-features
├── block
├── boot.img
├── build.config.cuttlefish.aarch64
├── build.config.cuttlefish.x86_64
├── certs
├── config.old
├── COPYING
├── CREDITS
├── crypto
├── Documentation
├── drivers
├── firmware
├── fs
├── include
├── init
├── ipc
├── Kbuild
├── Kconfig
├── kernel
├── kernel.img
├── lib
├── logo.bmp
├── MAINTAINERS
├── Makefile
├── mm
├── modules.builtin
├── modules.order
├── Module.symvers
├── net
├── README
├── REPORTING-BUGS
├── resource.img
├── samples
├── scripts
├── security
├── sound
├── System.map
├── tools
├── usr
├── verity_dev_keys.x509
├── virt
├── vmlinux
├── vmlinux.o
└── zboot.img

23 directories, 24 file
```

#### 目录说明

- arch：包含和硬件体系结构相关的代码，每种平台占一个相应的目录，如 i386、arm、arm64、powerpc、mips 等。Linux 内核目前已经支持30种左右的体系结构。
  - 在 arch 目录下，存放的是各个平台以及各个平台的芯片对 Linux 内核进程调度、内存管理、中断等的支持，以及每个具体的 SoC 和电路板的板级支持代码。
- block：块设备驱动程序 I/O 调度。
- crypto：常用加密和散列算法（如AES、SHA等)，还有一些压缩和 CRC 校验算法。
- documentation：内核各部分的通用解释和注释。
- drivers：设备驱动程序。每个不同的驱动占用一个子目录，如 char、block、net、mtd、 i2c 等。
- fs：所支持的各种文件系统，如EXT、FAT、NTFS、JFFS2等。
- include：内核 API 级別头文件，与系统相关的头文件放置在 include/linux 子目录下。
- init：内核初始化代码。著名的 stait_kemel() 就位于 init/main.c 文件中。
- ipc：进程间通信的代码。
- kernel：内核最核心的部分，包括进程调度、定时器等，而和平台相关的一部分代码放在 arch/*/kemel 目录下。
- lib：库文件代码。
- mm：内存管理代码，和平台相关的一部分代码放在arch/*/mm目录下。
- net：网络相关代码，实现各种常见的网络协议。
- scripts：用于配置内核的脚本文件。
- security：主要是一个 SELinux 的模块。
- sound：ALSA、OSS 音频设备的驱动核心代码和常用设备驱动。
- usr：实现用于打包和压缩的 cpio 等。
  

### 2.快速确定主板关联代码 

#### 板级基础代码 

Linux 移植通常分为体系结构级别移植、处理器级别移植和板级移植 。

- 确定体系架构相关的文件
  
  ```shell
  $ tree arch/arm64/ -L 1
  arch/arm64/
  ├── boot
  ├── configs
  ├── crypto
  ├── include
  ├── Kconfig
  ├── Kconfig.debug
  ├── Kconfig.platforms
  ├── kernel
  ├── kvm
  ├── lib
  ├── Makefile
  ├── mm
  ├── net
  └── xen
  ```
  
  - 确定内核配置文件，决定编译的内核模块和驱动。 
  
    - 如：默认内核配置文件为<arch/arm64/configs/rockchip_linux_defconfig> 
  
      ```shell
      # 部分内容
      CONFIG_DEFAULT_HOSTNAME="localhost"
      CONFIG_SYSVIPC=y
      CONFIG_POSIX_MQUEUE=y
      CONFIG_FHANDLE=y
      CONFIG_NO_HZ=y
      CONFIG_HIGH_RES_TIMERS=y
      CONFIG_LOG_BUF_SHIFT=18
      CONFIG_CGROUPS=y
      CONFIG_CGROUP_FREEZER=y
      CONFIG_CGROUP_PIDS=y
      CONFIG_CGROUP_DEVICE=y
      CONFIG_CPUSETS=y
      CONFIG_CGROUP_CPUACCT=y
      CONFIG_MEMCG=y
      CONFIG_MEMCG_SWAP=y
      CONFIG_CGROUP_PERF=y
      CONFIG_CGROUP_SCHED=y
      CONFIG_CFS_BANDWIDTH=y
      CONFIG_RT_GROUP_SCHED=y
      CONFIG_BLK_CGROUP=y
      CONFIG_NAMESPACES=y
      CONFIG_USER_NS=y
      ...
      ```
  
  - 确定设备树文件，决定板级外设配置
  
    - 如：<arch/arm64/boot/dts/rockchip/rk3399-firefly-aioc.dts>
- 确定对应的主板文件（32位板子）。 
  - 如：<arch/arm/mach-omap2/board-am335xevm.c> 
  - <arch/arm/mach-mxs/mach-mx28evk.c> 

#### 驱动代码 

​	驱动代码在drivers 目录 

#### 其它代码 

​	文件系统的实现代码、网络子系统的实现代码等。 



### 2.Linux 内核中的 Makefile 文件 

#### 1）顶层 Makefile 

源码目录树顶层 Makefile 是整个内核源码管理的入口，对整个内核的源码编译起着决定性作用。编译内核时，顶层 Makefile 会按规则递归历遍内核源码的所有子目录下的Makefile 文件，完成各子目录下内核模块的编译。 

##### 内核版本号 

顶层 Makefile，开头的几行记录了内核源码的版本号 。

```makefile
VERSION = 2
PATCHLEVEL = 6
SUBLEVEL = 35
EXTRAVERSION =3
#说明代码版本为 2.6.35.3
```

内核在目标板运行后，输入 uname -a 命令可以得到印证 。

##### 编译控制 

- 体系结构 

  - Linux 是一个支持众多体系结构的操作系统，在编译过程中需指定体系结构，以与实际平台对应。在顶层 Makefile 中，通过变量 ARCH 来指定 。

  - ```makefile
    ARCH ?= $(SUBARCH)
    #如果进行 ARM 嵌入式 Linux 开发，则必须指定 ARCH 为 arm（注意大小写，须与 arch/目录下的 arm 一致）
    #如：$make ARCH=arm
    ```

- 编译器 

  - 进行 ARM 嵌入式 Linux 开发，必须指定交叉编译器，可以在内核配置通过 CONFIG_CROSS_COMPILE 指定交叉编译器，也可以通过 CROSS_COMPILE 指定。 

    ```shell
  $ make ARCH=arm CROSS_COMPILE= arm-linux-gnueabihf-
    ```
  
    ```makefile
  CROSS_COMPILE = arm-linux-gnueabihf-
    #注意： CROSS_COMPILE 指定的交叉编译器必须事先安装并正确设置系统环境变量； 如果没有设置环境变量， 则需使用绝对地址
    ```
  

#### 2）子目录的 Makefile 

几乎每个子目录都有相应的 Makefile 文件，管理着对应目录下的代码。 

Makefile 中有两种表示方式：

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



### 3.Linux 内核中的 Kconfig 文件 

​	内核源码树每个目录下都还包含一个 Kconfig 文件，用于描述所在目录源代码相关的内核配置菜单，各个目录的 Kconfig 文件构成了一个分布式的内核配置数据库。

​	通过 make menuconfig（make xconfig 或者 make gconfig）命令配置内核的时候，从 Kconfig 文件读取单，配置完毕保存到文件名为.config 的内核配置文件中，供 Makefile 文件在编译内核时使用。 

#### 1）Kconfig的格式

​	Kconfig按照一定的格式来书写，menuconfig程序可以识别这种格式，然后从中提取出有效信息组成menuconfig中的菜单项。

​	截取/drivers/net下的Kconfig文件中的部分内容：

```shell
# Network device configuration
menuconfig NETDEVICES
        default y if UML
        depends on NET
        bool "Network device support"
        ---help---
          You can say N here if you don't intend to connect your Linux box to any other computer at all.
……
config DM9000
        tristate "DM9000 support"
        depends on ARM || BLACKFIN || MIPS
        select CRC32
        select MII
        ---help---
          Support for DM9000 chipset.

          To compile this driver as a module, choose M here.  The module will be called dm9000.
……
source "drivers/net/arcnet/Kconfig"
source "drivers/net/phy/Kconfig"
```

- menuconfig：表示菜单（本身属于一个菜单中的项目，但是又有子菜单项目）、config表示菜单中的一个配置项（本身并没有子菜单下的项目）。一个menuconfig后面跟着的所有config项就是这个menuconfig的子菜单。这就是Kconfig中表示的目录关系。
- NETDEVICES：配置项名字，用大写字母表示。这个字符串前面添加CONFIG_后就构成了“.config”文件中的配置项名字。
- source：内核源码目录树中每一个Kconfig都会用source引入其所有子目录下的Kconfig，从而保证了所有的Kconfig项目都被包含进menuconfig中。
  - 如果在linux内核中添加了一个文件夹，一定要在这个文件夹下创建一个Kconfig文件，然后在这个文件夹的上一层目录的Kconfig中source引入这个文件夹下的Kconfig文件。
- tristate：意思是三态（3种状态，对应Y、N、M三种选择方式），意思就是这个配置项可以被三种选择。
- bool：是要么真要么假（对应Y和N）。意思是这个配置项只能被2种选择。
- depends：意思是本配置项依赖于另一个配置项。如果那个依赖的配置项为Y或者M，则本配置项才有意义；如果依赖的哪个配置项本身被设置为N，则本配置项根本没有意义。
- select：表示depends on的值有效时，下面的select也会成立，将相应的内容选上。
- default：表示depends on的值有效时，下面的default也会成立，将相应的选项选上，有三种选项，分别对应y，n，m。
- help：帮助信息，解释这个配置项的含义，以及如何去配置他。

#### 2）Kconfig和.config文件和Makefile三者的关联

- 配置项被配置成Y、N、M会影响“.config”文件中的CONFIG_XXX变量的配置值。
- .config”中的配置值（=y、=m、没有）会影响最终的Makefile编译链接过程，如makefile中：obj-$(CONFIG_DM9000) += dm9000.o
  - 如果=y则会被编入（built-in）；
  - 如果=m会被单独连接成一个”.ko”内核模块（需要insmod动态加载到内核中）；
  - 如果没有则对应的代码不会被编译。



### 4.Linux 内核源码配置执行过程

关键文件

- Kconfig ---> （每个源码目录下）提供选项
- .config ---> （源码顶层目录下）保存选择结果
- Makefile---> （每个源码目录下）根据.config中的内容来告知编译系统如何编译

#### 1）执行步骤

- 系统读取arch/$ARCH/目录下的Kconfig文件生成整个配置界面选项（Kconfig是整个linux配置机制的核心）。

  - 那么ARCH环境变量的值由linux内核根目录下的makefile文件决定的，在makefile有此环境变量的定义。
  - 或者通过 make ARCH=arm menuconfig命令来生成配置界面。

- 修改内核配置后，当保存make menuconfig选项时，系统会将配置保存在内核根目录下.config文件。还会将所有的选项以宏的形式保存在Linux内核根目录下的 include/generated/autoconf.h文件下。

  - 内核有默认配置选项提供，存放在arch/$ARCH/configs下，可以将所需的配置复制到内核根目录下.config文件。

    ```shell
    $ cp arch/arm64/configs/rockchip_linux_defconfig .config
    ```

  - 注意：Kconfig文件的配置项，如“config DM9000”，会在.config目录下生成“CONFIG_DM9000=x”，所以Makefile文件中是使用“obj-$(CONFIG_DM9000) += DM9000.o”

- 执行make编译，会根据.config文件所配置的选项（=y、=m、没有）逐个进行编译。

  - 或者可以指定编译配置文件

    ```shell
    # Kernel defconfig
    export RK_KERNEL_DEFCONFIG=rockchip_linux_defconfig
    # Kernel dts
    export RK_KERNEL_DTS=rk3399-firefly-aioc
    
    $ make ARCH=arm64 $RK_KERNEL_DEFCONFIG
    $ make ARCH=arm64 $RK_KERNEL_DTS.img
    ```



## 二、配置和编译 Linux 内核 

### 1.快速配置内核 

进入 Linux 内核源码数顶层目录，输入 make menuconfig 命令 。

注意： 主机须安装 ncurses 相关库才能正确运行该命令并出现配置界面 。



如果没有在 Makefile 中指定 ARCH，则须在命令行中指定 

```shell
$ make ARCH=arm menuconfig
```



### 2.内核配置详情 

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

#### 1）通用设置  General setup  

| 选项                                       | 说明                                       |
| ---------------------------------------- | ---------------------------------------- |
| ( ) Cross-compiler tool prefix           | 交叉编译器前缀，将会设置 CONFIG_CROSS_COMPILE 变量， 等同于 make CROSS_COMPILE=prefix- |
| ( ) Local version - append to kernel release | 填写本地版本                                   |
| [ ] Automatically append version informationto the version string | 自动增加版本信息。如果用了 Git 管理内核源码，每次 Git提交都会造成内核版本号增加。谨慎使用该选项 |
| < > Kernel .config support               | 选中该选项会将当前内核配置信息保存到内核中                    |
| [ ] Enable access to .config through/proc/config.gz | 通过/proc/config.gz 获得当前运行内核的配置信息。建议选中     |
| [ ] Initial RAM filesystem and RAM disk(initramfs/initrd) support | Initramfs 支持，使能该特性可以将一个文件系统打包到内核文件中，内核启动不需要额外的文件系统 |
| ( ) Initramfs source file(s)             | Initramfs 文件系统的路径，通常放在源码树 usr 目录下        |

#### 2）内核特性  Kernel Features  

| 选项                                       | 说明                                       |
| ---------------------------------------- | ---------------------------------------- |
| [ ] Tickless System (Dynamic Ticks)      | 无时钟系统支持，根据系统运行状况来启用或者禁用时钟，能让内核运行更有效且更省电。 A8 这样的处理器建议选中 |
| [ ] High Resolution Timer Support        | 高精度定时器。处理器支持则可选中                         |
| Memory split (3G/1G user/kernel split)---> | 4G 内存分割比例，内核和用户空间： 3G/1G、 2G/2G、 1G/2G。早期内核是 3G/1G 固定分割，目前可配置 |
| Preemption Model (No Forced Preemption(Server)) ---> | 内核抢占模式，可选值：No Forced Preemption (Server)Voluntary Kernel Preemption (Desktop)Preemptible Kernel (Low-Latency Desktop)需要实时性则须设置为 Preemptible Kernel |
| [ ] Compile the kernel in Thumb-2 mode(EXPERIMENTAL) | 以 Thumb-2 指令集编译内核。不推荐                    |
| [ ] High Memory Support                  | 高端内存，嵌入式系统通常不用选                          |

#### 3）启动选项 

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

#### 4）网络支持 

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

#### 5）设备驱动 

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

#### 6）文件系统  File systems 

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



### 3.编译内核 

#### 1）从内核码源编译成zImage

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



#### 2）把zImage转为uImage

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

#### 3）从内核源码直接生成 uImage

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



#### 4）编译内核模块 

如果内核中有配置为<M>的模块或者驱动，需要在编译内核后再通过 make modules 命
令编译这些模块或者驱动 

```shell
$ make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- modules
```

编译得到的内核模块文件以“.ko”结尾，这些可以通过 insmod 命令插入到运行的内核中。 

```shell
$ insmod kernel/drivers/net/bonding/bonding.ko
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



### 4.运行内核 

得到 uImage 映像文件后，将 uImage 加载到内存地址 ep-0x40 处（0x40007fc0），通过 bootm 命令即可运行内核： 

```shell
# tftp 40007fc0 uImage
# bootm 40007fc0
```

