### 特殊文件系统

#### 1.proc文件系统

- /proc是一个位于内存中的伪文件系统(in-memory pseudo-file system)。该目录下保存的不是真正的文件和目录，而是一些“运行时”信息，如系统内存、磁盘io、设备挂载信息和硬件配置信息等。
- proc目录是一个控制中心，用户可以通过更改其中某些文件来改变内核的运行状态。
- proc目录也是内核提供给我们的查询中心，我们可以通过这些文件查看有关系统硬件及当前正在运行进程的信息。

- proc文件系统提供了[内核空间](https://en.wikipedia.org/wiki/Kernel_space)和[用户空间](https://en.wikipedia.org/wiki/User_space)之间的通信方法。

##### 1）proc各目录说明

- /proc/buddyinfo 每个内存区中的每个order有多少块可用，和内存碎片问题有关
- /proc/cmdline 启动时传递给kernel的参数信息
- /proc/cpuinfo cpu的信息
- /proc/crypto 内核使用的所有已安装的加密密码及细节
- /proc/devices 已经加载的设备
- /proc/dma 已注册使用的ISA DMA频道列表
- /proc/execdomains linux内核当前支持的execution domains
- /proc/fb 帧缓冲设备列表，包括数量和控制它的驱动
- /proc/filesystems 内核当前支持的文件系统类型
- /proc/interrupts x86架构中的每个IRQ中断数
- /proc/iomem 每个物理设备当前在系统内存中的映射
- /proc/ioports 一个设备的输入输出所使用的注册端口范围
- /proc/kcore 代表系统的物理内存，存储为核心文件格式，里边显示的是字节数，等于RAM大小加上4kb
- /proc/kmsg 记录内核生成的信息，可以通过/sbin/klogd或/bin/dmesg来处理
- /proc/loadavg 根据过去一段时间内CPU和IO的状态得出的负载状态，与uptime命令有关
- /proc/locks 内核锁住的文件列表
- /proc/mdstat 多硬盘，RAID配置信息(md=multiple disks)
- /proc/meminfo RAM使用的相关信息
- /proc/misc 其他的主要设备(设备号为10)上注册的驱动
- /proc/modules 所有加载到内核的模块列表
- /proc/mounts 系统中使用的所有挂载
- /proc/mtrr 系统使用的Memory Type Range Registers (MTRRs)
- /proc/partitions 分区中的块分配信息
- /proc/pci 系统中的PCI设备列表
- /proc/slabinfo 系统中所有活动的 slab 缓存信息
- /proc/stat 所有的CPU活动信息
- /proc/sysrq-trigger 使用echo命令来写这个文件的时候，远程root用户可以执行大多数的系统请求关键命令，就好像在本地终端执行一样。要写入这个文件，需要把/proc/sys/kernel/sysrq不能设置为0。这个文件对root也是不可读的
- /proc/uptime 系统已经运行了多久
- /proc/swaps 交换空间的使用情况
- /proc/version Linux内核版本和gcc版本
- /proc/bus 系统总线(Bus)信息，例如pci/usb等
- /proc/driver 驱动信息
- /proc/fs 文件系统信息
- /proc/ide ide设备信息
- /proc/irq 中断请求设备信息
- /proc/net 网卡设备信息
- /proc/scsi scsi设备信息
- /proc/tty tty设备信息
- /proc/net/dev 显示网络适配器及统计信息
- /proc/vmstat 虚拟内存统计信息
- /proc/vmcore 内核panic时的内存映像
- /proc/diskstats 取得磁盘信息
- /proc/schedstat kernel调度器的统计信息
- /proc/zoneinfo 显示内存空间的统计信息，对分析虚拟内存行为很有用

##### 2）进程目录/proc/[pid]说明

- /proc/N pid为N的进程信息
- /proc/N/cmdline 进程启动命令
- /proc/N/cwd 链接到进程当前工作目录
- /proc/N/environ 进程环境变量列表
- /proc/N/exe 链接到进程的执行命令文件
- /proc/N/fd 包含进程相关的所有的文件描述符
- /proc/N/maps 与进程相关的内存映射信息
- /proc/N/mem 指代进程持有的内存，不可读
- /proc/N/root 链接到进程的根目录
- /proc/N/stat 进程的状态
- /proc/N/statm 进程使用的内存的状态
- /proc/N/status 进程状态信息，比stat/statm更具可读性
- /proc/self 链接到当前正在运行的进程



#### 2.sysfs伪文件系统

- sysfs是**linux内核模块在用户空间的映射**，sysfs通过ramfs实现，与kobject密切相关。用于将系统中的设备组织成层次结构，并向用户模式程序提供详细的内核数据结构信息。

- 挂载到 /sys 目录下，在用户态可以通过对sys文件系统的访问，来看内核态的一些驱动或者设备等。

- 手动挂载sysfs

  ```shell
  mount -t sysfs sysfs /sys 
  ```

##### 1）/sys目录说明

![](https://upload-images.jianshu.io/upload_images/15877540-3756c6a07e02e1fd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##### 2）sysfs与proc的关系

- 在 sysfs 下的很多 kobject 下都有 uevent 属性，用于内核与 udev (自动设备发现程序)之间的一个通信接口；
- netlink 协议套接字是udev 与内核的通信接口；
- uevent 属性文件一般都是可写的，可以向 udevd  (udev 后台程序)发送一条 netlink 消息，让它再重新一遍相关的 udev 规则文件，从而让用户空间的udev动态创建或删除设备文件；



#### 3.devfs设备文件系统

- 存在于内核空间，在linux2.6之后被抛弃，内核空间的devfs被用户空间的udev取代。
- 特点：
  - 设备文件被打开时才加载驱动
  - 由内核管理设备文件名称



#### 4.udev设备管理器

​	**udev** 是Linux kernel 2.6系列的设备管理器，运行在应用层。它主要的功能是管理`/dev`目录底下的[设备节点](https://zh.wikipedia.org/w/index.php?title=设备节点&action=edit&redlink=1)。它同时也是用来接替[devfs](https://zh.wikipedia.org/wiki/Devfs)及[hotplug](https://zh.wikipedia.org/w/index.php?title=Hotplug&action=edit&redlink=1)的功能，这意味着它要在添加/删除硬件时处理`/dev`目录以及所有用户空间的行为，包括加载[firmware](https://zh.wikipedia.org/wiki/Firmware)时。

##### 1）运行方式

- 动态管理：当内核检测到系统出现新设备时，内核通过netlink套接字发送uevent；udev是在用户空间运行的守护进程，会监听内核的uevent事件（通过[netlink](https://zh.wikipedia.org/wiki/Netlink) socket），根据事件和配置的udev规则添加或者删除设备文件。
- 自定义命名规则：通过 Linux 默认的规则文件，udev 在 /dev/ 里为所有的设备定义了内核设备名称，比如 `/dev/sda、/dev/hda、/dev/fd`等等。由于 udev 是在用户空间 (user space) 运行，Linux 用户可以通过自定义的规则文件，灵活地产生标识性强的设备文件名，如/dev/ttyGPS。
- 设定设备的权限和所有者 / 组：udev 可以按一定的条件来设置设备文件的权限和设备文件所有者 / 组。

![](https://img-blog.csdn.net/20150617135747793?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQveGlhb2xpdTUzOTY=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

##### 2）udev组成

udev系统可以分为三个部分：

- libudev函数库，可以用来获取设备的信息。

- udevd守护进程，处于用户空间，用于管理虚拟`/dev`

- 管理命令udevadm，用来诊断出错情况。

  ```shell
  $ udevadm info /dev/ttyTHS1
  P: /devices/70006040.serial/tty/ttyTHS1
  N: ttyTHS1
  E: DEVNAME=/dev/ttyTHS1
  E: DEVPATH=/devices/70006040.serial/tty/ttyTHS1
  E: ID_MM_CANDIDATE=1
  E: MAJOR=238
  E: MINOR=1
  E: SUBSYSTEM=tty
  E: TAGS=:systemd:
  E: USEC_INITIALIZED=4078860
  E: net.ifnames=0
  ```

##### 3）udev规则和文件

- udev配置文件是/etc/udev/udev.conf，指定udev规则存储的目录，默认为udev_rules=“/etc/udev/rules.d”。

- 目录中存储一系列以.rules结束的规则文件，每个文件处理一系列规则来帮助udev分配名字给设备文件并保证内核可以识别此名字。

  ```shell
  root@michael-desktop:/etc/udev/rules.d# ls -l
  total 32
  -rw-r--r-- 1 root root  497 Jul 17 08:19 90-alsa-asound-tegra.rules
  -rw-r--r-- 1 root root  175 Jul 17 08:19 91-xorg-conf-tegra.rules
  -rw-r--r-- 1 root root  711 Jul 17 08:19 92-hdmi-audio-tegra.rules
  -rw-r--r-- 1 root root  208 Jul 17 08:19 99-nv-l4t-usb-device-mode.rules
  -rw-r--r-- 1 root root  634 Jul 17 08:19 99-nv-wifibt.rules
  -rw-r--r-- 1 root root 1425 Jul 17 08:19 99-tegra-devices.rules
  -rw-r--r-- 1 root root  130 Jul 17 08:19 99-tegra-mmc-ra.rules
  -rw-r--r-- 1 root root  157 Aug 14 14:10 ttyUSB.rules
  ```

- 规则文件由系列键-值对组成，匹配键和赋值键操作符解释如下

  ```shell
  操作符     匹配或赋值                         解释
  －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
       ==            匹配              相等比较
       !=            匹配              不等比较
       =             赋值              分配一个特定的值给该键,他可以覆盖之前的赋值.
       +=            赋值              追加特定的值给已经存在的键
       :=            赋值              分配一个特定的值给该键,后面的规则不可能覆盖它.
  ```

- 所有键列表

  ```shell
  键                	含义
  －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
  # 配对关键字
  ACTION               事件 (uevent) 的行为,例如：add( 添加设备 )、remove( 删除设备 ).
  KERNEL               在内核里看到的设备名字,比如sd*表示任意SCSI磁盘设备
  DEVPATH              内核设备路径,比如/devices/*
  SUBSYSTEM            设备子系统名字,例如：sda 的子系统为 block.
  BUS                  总线的名字,比如IDE,USB
  DRIVER               设备驱动的名字,比如ide-cdrom
  ID                   独立于内核名字的设备名字
  SYSFS{ value}        sysfs属性值,他可以表示任意
  ATTRS 				 匹配设备的sysfs属性，或任何父设备的sysfs属性
  ENV{ key}            环境变量,可以表示任意
  PROGRAM              可执行的外部程序,如果程序返回0值,该键则认为为真(true)
  RESULT               上一个PROGRAM调用返回的标准输出.
  
  # 赋值关键字
  NAME                 根据这个规则创建的设备文件的文件名.
  （注意：仅仅第一行的NAME描述是有效的,后面的均忽略.如果你想使用使用两个以上的名字来访问一个设备的话,可以考虑SYMLINK键.)
  SYMLINK              为 /dev/下的设备文件产生符号链接.由于 udev 只能为某个设备产生一个设备文件,
  （所以为了不覆盖系统默认的 udev 规则所产生的文件,推荐使用符号链接.）
  OWNER                设备文件的属组
  GROUP                设备文件所在的组.
  MODE                 设备文件的权限,采用8进制
  RUN                  为设备而执行的程序列表
  LABEL                在配置文件里为内部控制而采用的名字标签(下下面的GOTO服务)
  GOTO                 跳到匹配的规则（通过LABEL来标识）,有点类似程序语言中的GOTO
  IMPORT{ type}        导入一个文件或者一个程序执行后而生成的规则集到当前文件
  WAIT_FOR_SYSFS       等待一个特定的设备文件的创建.主要是用作时序和依赖问题.
  PTIONS               特定的选项：
  last_rule            对这类设备终端规则执行；
  ignore_device        忽略当前规则；
  ignore_remove        忽略接下来的并移走请求.
  all_partitions       为所有的磁盘分区创建设备文件.
  ```

- 特殊的值和替换值

  ```shell
  例如：my_root_disk, my_printer.同时也可以引用下面的替换操作符：
  －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
  $kernel,       %k：       设备的内核设备名称,例如：sda、cdrom.
  $number,       %n：       设备的内核号码,例如：sda3 的内核号码是 3.
  $devpath,      %p：       设备的 devpath路径.
  $id,           %b：       设备在 devpath里的 ID 号.
  $sysfs{file},  %s{file}： 设备的 sysfs里 file 的内容.其实就是设备的属性值.
  $env{key},     %E{key}：   一个环境变量的值.
  $major,        %M：        设备的 major 号.
  $minor，       %m：        设备的 minor 号.
  $result,       %c：        PROGRAM 返回的结果
  $parent,       %P：        父设备的设备文件名.
  $root,         %r：        udev_root的值,默认是 /dev/.
  $tempnode,     %N：        临时设备名.
  %%：           符号 % 本身.
  $$：           符号 $ 本身.
  ```

##### 4）编写udev规则步骤

​	[编写udev规则](http://www.reactivated.net/writing_udev_rules.html)

- 使用udevadm info 工具获取设备内核信息和sysfs属性信息

  ```shell
  $ udevadm info --attribute-walk --name=/dev/ttyUSB0
  # or
  $ udevadm info -a -p /sys/bus/usb-serial/devices/ttyUSB0
  Udevadm info starts with the device specified by the devpath and then
  walks up the chain of parent devices. It prints for every device
  found, all possible attributes in the udev rules key format.
  A rule to match, can be composed by the attributes of the device
  and the attributes from one single parent device.
  
    looking at device '/devices/70090000.xusb/usb1/1-2/1-2.1/1-2.1:1.0/ttyUSB0/tty/ttyUSB0':
      KERNEL=="ttyUSB0"
      SUBSYSTEM=="tty"
      DRIVER==""
  
    looking at parent device '/devices/70090000.xusb/usb1/1-2/1-2.1/1-2.1:1.0/ttyUSB0':
      KERNELS=="ttyUSB0"
      SUBSYSTEMS=="usb-serial"
      DRIVERS=="ch341-uart"
      ATTRS{port_number}=="0"
  
    looking at parent device '/devices/70090000.xusb/usb1/1-2/1-2.1/1-2.1:1.0':
      KERNELS=="1-2.1:1.0"
      SUBSYSTEMS=="usb"
      DRIVERS=="ch341"
      ATTRS{authorized}=="1"
      ATTRS{bAlternateSetting}==" 0"
      ATTRS{bInterfaceClass}=="ff"
      ATTRS{bInterfaceNumber}=="00"
      ATTRS{bInterfaceProtocol}=="02"
      ATTRS{bInterfaceSubClass}=="01"
      ATTRS{bNumEndpoints}=="03"
      ATTRS{supports_autosuspend}=="1"
  
    looking at parent device '/devices/70090000.xusb/usb1/1-2/1-2.1':
      KERNELS=="1-2.1"
      SUBSYSTEMS=="usb"
      DRIVERS=="usb"
      ATTRS{authorized}=="1"
      ATTRS{avoid_reset_quirk}=="0"
      ATTRS{bConfigurationValue}=="1"
      ATTRS{bDeviceClass}=="ff"
      ATTRS{bDeviceProtocol}=="00"
      ATTRS{bDeviceSubClass}=="00"
      ATTRS{bMaxPacketSize0}=="8"
      ATTRS{bMaxPower}=="98mA"
      ATTRS{bNumConfigurations}=="1"
      ATTRS{bNumInterfaces}==" 1"
      ATTRS{bcdDevice}=="0263"
      ATTRS{bmAttributes}=="80"
      ATTRS{busnum}=="1"
      ATTRS{configuration}==""
      ATTRS{devnum}=="5"
      ATTRS{devpath}=="2.1"
      ATTRS{idProduct}=="7523"
      ATTRS{idVendor}=="1a86"
      ATTRS{ltm_capable}=="no"
      ATTRS{maxchild}=="0"
      ATTRS{product}=="USB2.0-Serial"
      ATTRS{quirks}=="0x0"
      ATTRS{removable}=="unknown"
      ATTRS{speed}=="12"
      ATTRS{urbnum}=="20"
      ATTRS{version}==" 1.10"
  
    looking at parent device '/devices/70090000.xusb/usb1/1-2':
      KERNELS=="1-2"
      SUBSYSTEMS=="usb"
      DRIVERS=="usb"
      ATTRS{authorized}=="1"
      ATTRS{avoid_reset_quirk}=="0"
      ATTRS{bConfigurationValue}=="1"
      ATTRS{bDeviceClass}=="09"
      ATTRS{bDeviceProtocol}=="02"
      ATTRS{bDeviceSubClass}=="00"
      ATTRS{bMaxPacketSize0}=="64"
      ATTRS{bMaxPower}=="0mA"
      ATTRS{bNumConfigurations}=="1"
      ATTRS{bNumInterfaces}==" 1"
      ATTRS{bcdDevice}=="0120"
      ATTRS{bmAttributes}=="e0"
      ATTRS{busnum}=="1"
      ATTRS{configuration}==""
      ATTRS{devnum}=="2"
      ATTRS{devpath}=="2"
      ATTRS{idProduct}=="5411"
      ATTRS{idVendor}=="0bda"
      ATTRS{ltm_capable}=="no"
      ATTRS{manufacturer}=="Generic"
      ATTRS{maxchild}=="4"
      ATTRS{product}=="4-Port USB 2.1 Hub"
      ATTRS{quirks}=="0x0"
      ATTRS{removable}=="unknown"
      ATTRS{speed}=="480"
      ATTRS{urbnum}=="96"
      ATTRS{version}==" 2.10"
  
    looking at parent device '/devices/70090000.xusb/usb1':
      KERNELS=="usb1"
      SUBSYSTEMS=="usb"
      DRIVERS=="usb"
      ATTRS{authorized}=="1"
      ATTRS{authorized_default}=="1"
      ATTRS{avoid_reset_quirk}=="0"
      ATTRS{bConfigurationValue}=="1"
      ATTRS{bDeviceClass}=="09"
      ATTRS{bDeviceProtocol}=="01"
      ATTRS{bDeviceSubClass}=="00"
      ATTRS{bMaxPacketSize0}=="64"
      ATTRS{bMaxPower}=="0mA"
      ATTRS{bNumConfigurations}=="1"
      ATTRS{bNumInterfaces}==" 1"
      ATTRS{bcdDevice}=="0409"
      ATTRS{bmAttributes}=="e0"
      ATTRS{busnum}=="1"
      ATTRS{configuration}==""
      ATTRS{devnum}=="1"
      ATTRS{devpath}=="0"
      ATTRS{idProduct}=="0002"
      ATTRS{idVendor}=="1d6b"
      ATTRS{interface_authorized_default}=="1"
      ATTRS{ltm_capable}=="no"
      ATTRS{manufacturer}=="Linux 4.9.140-tegra xhci-hcd"
      ATTRS{maxchild}=="5"
      ATTRS{product}=="xHCI Host Controller"
      ATTRS{quirks}=="0x0"
      ATTRS{removable}=="unknown"
      ATTRS{serial}=="70090000.xusb"
      ATTRS{speed}=="480"
      ATTRS{urbnum}=="79"
      ATTRS{version}==" 2.00"
  
    looking at parent device '/devices/70090000.xusb':
      KERNELS=="70090000.xusb"
      SUBSYSTEMS=="platform"
      DRIVERS=="tegra-xusb"
      ATTRS{downgrade_usb3}=="0"
      ATTRS{driver_override}=="(null)"
      ATTRS{hsic_power}=="0"
  ```

- 如对两个usb转ttl设备生成新的符号链接

  ```shell
  $ cat ttyUSB.rules 
  ATTRS{serial}=="A5XK3RJT", MODE:="0777", GROUP:="dialout", SYMLINK+="ttyGPS"
  ATTRS{serial}=="AH072FQW", MODE:="0777", GROUP:="dialout", SYMLINK+="ttyHandle"
  ```
  
  - 使用配对关键字serial来匹配唯一id，使用赋值关键字MODE、GROUP和SYMLINK设置新的属性