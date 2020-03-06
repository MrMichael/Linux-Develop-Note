[TOC]

###  一、Linux内核简介

#### 1.宏内核与微内核

内核分为四大类：单内核（宏内核）；微内核；混合内核；外内核。

- 宏内核(Monolithickernel)是将内核从整体上作为一个大过程来实现，所有的内核服务都在一个地址空间运行，相互之间直接调用函数，简单高效。
  - Linux虽是宏内核，但已吸收了微内核的部分精华。Linux是模块化的、多线程的、内核本身可调度的系统，既吸收了微内核的精华，又保留了宏内核的优点，无需消息传递，避免性能损失。
- 微内核(Microkernel)功能被划分成独立的过程，过程间通过IPC进行通信，模块化程度高，一个服务失效不会影响另外一个服务。

![](https://img-blog.csdn.net/20160827082557413)

#### 2.Linux体系架构

从两个层次上来考虑操作系统

- 用户空间：包含了用户的应用程序和C库
  - GNU C Library （glibc）提供了连接内核的系统调用接口，还提供了在用户空间应用程序和内核之间进行转换的机制。
- 内核空间：包含了系统调用，内核，以及与平台架构相关的代码

![](https://img-blog.csdn.net/20160827084044566)

划分原因

- 现代CPU通常都实现了不同的工作模式

  - 以ARM为例：ARM实现了7种工作模式，不同模式下CPU可以执行的指令或者访问的寄存器不同：
    - （1）用户模式 usr 
    - （2）系统模式 sys
    - （3）管理模式 svc
    - （4）快速中断 fiq
    - （5）外部中断 irq
    - （6）数据访问终止 abt
    - （7）未定义指令异常； 

  - 以X86为例：X86实现了4个不同级别的权限，Ring0—Ring3 ;Ring0下可以执行特权指令，可以访问IO设备；Ring3则有很多的限制。

- 为了保护内核的安全，把系统分成了2部分：用户空间和内核空间是程序执行的两种不同状态，我们可以通过“系统调用”和“硬件中断“来完成用户空间到内核空间的转移；

#### 3.Linux的内核结构

Linux内核是整体式结构（宏内核），各个子系统联系紧密，作为一个大程序在内核空间运行。

系统调用接口（system call interface，SCI）提供了某些机制执行从用户空间到内核的函数调用。

![](https://img-blog.csdn.net/20160827081631860)

##### 1）Linux内核组成（子系统）

- 进程调度（SCHED）：控制多个进程对CPU的访问。当需要选择下一个进程运行时，由调度程序选择最值得运行的进程。可运行进程实际上是仅等待CPU资源的进程，如果某个进程在等待其它资源，则该进程是不可运行进程。Linux使用了比较简单的基于优先级的进程调度算法选择新的进程。

- 内存管理（memory management，MM）：允许多个进程安全的共享主内存区域。Linux 的内存管理支持虚拟内存，即在计算机中运行的程序，其代码，数据，堆栈的总量可以超过实际内存的大小，操作系统只是把当前使用的程序块保留在内存中，其余的程序块则保留在磁盘中。必要时，操作系统负责在磁盘和内存间交换程序块。内存管理从逻辑上分为硬件无关部分和硬件有关部分。硬件无关部分提供了进程的映射和逻辑内存的对换；硬件相关的部分为内存管理硬件提供了虚拟接口。

  - 一般而言，Linux的每个进程享有4GB的内存空间，0~3GB属于用户空间，3~4GB属于内核空间。

- 虚拟文件系统（Virtual File System,VFS）：隐藏了各种硬件的具体细节，为所有的设备提供了统一的接口，VFS提供了多达数十种不同的文件系统。虚拟文件系统可以分为逻辑文件系统和设备驱动程序。逻辑文件系统指Linux所支持的文件系统，如ext2,fat等，设备驱动程序指为每一种硬件控制器所编写的设备驱动程序模块。

  ![](https://www.ibm.com/developerworks/cn/linux/l-linux-kernel/figure4.jpg)

- 网络接口（NET）：提供了对各种网络标准的存取和各种网络硬件的支持。网络接口可分为网络协议和网络驱动程序。网络协议部分负责实现每一种可能的网络传输协议。网络设备驱动程序负责与硬件设备通讯，每一种可能的硬件设备都有相应的设备驱动程序。

  ![](http://s6.sinaimg.cn/middle/67146a75ga2246e83ebc5&690)

- 进程间通讯(inter-process communication，IPC)： 支持进程间各种通信机制。

  - 共享内存
  - 管道
  - 信号量
  - 消息队列
  - 套接字

#### 4.内核模块

Linux内核是模块化组成的，它允许内核在运行时动态地向其中插入或删除代码。



### 二、内核模块结构

#### 1.头文件 

内核模块头文件<linux/module.h>和<linux/init.h>是必不可少的 ，不同模块根据功能的差异，所需要的头文件也不相同 。

```C
#include <linux/module.h>
#include <linux/init.h>
```

#### 2.模块初始化 

模块的初始化负责注册模块本身 ，只有已注册模块的各种方法才能够被应用程序使用并发挥各方法的实际功能。 

模块并不是内核内部的代码，而是独立于内核之外，通过初始化，能够让内核之外的代码来替内核完成本应该由内核完成的功能，模块初始化的功能相当于模块与内核之间衔接的桥梁，告知内核已经准备好模块了。

**内核模块初始化函数**

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

#### 3.模块退出 

模块的退出相当于告知内核“我要离开了，将不再为您服务了”。 

内核模块退出函数

```c
//模块退出函数没有返回值；
//__exit 标记这段代码仅用于模块卸载；
static void __exit module_exit_func(void)
{
	//模块退出代码
}
module_exit(module_exit_func);
//没有 module_exit 定义的模块无法被卸载
```

当使用 rmmod 卸载模块时，退出函数的代码将被执行。 

> 注意：如果模块被编译进内核，而不是动态加载，则__init的使用会在模块初始化完成后丢弃该函数并回收所占内存, _exit宏将忽略“清理收尾”的函数。

#### 4.模块许可证声明 

Linux 内核是开源的，遵守 GPL 协议，所以要求加载进内核的模块也最好遵循相关协议。 

为模块指定遵守的协议用 MODULE_LINCENSE 来声明 :

```c
MODULE_LICENSE("GPL");
```

- 内核能够识别的协议有
  - “GPL”
  - “GPL v2”
  - “GPL and additional rights（GPL 及附加权利）”
  - “Dual BSD/GPL（BSD/GPL 双重许可）”
  - “Dual MPL/GPL（MPL/GPL 双重许可）”
  - “Proprietary（私有）”

#### 5.模块导出符号 【可选】

使用模块导出符号，方便其它模块依赖于该模块，并使用模块中的变量和函数等。

- 在Linux2.6的内核中，/proc/kallsyms文件对应着符号表，它记录了符号和符号对应的内存地址。

  ```shell
  $ cat /proc/kallsyms 
  ...
  ffffff80084039b8 t shash_digest_unaligned
  ffffff8008403a30 T crypto_shash_digest
  ffffff8008403ac0 t shash_async_final
  ffffff8008403af0 T shash_ahash_update
  ffffff8008403b50 t shash_async_update
  ffffff8008403b80 t crypto_exit_shash_ops_async
  ffffff8008403bb0 t crypto_shash_report
  ffffff8008403c18 t crypto_shash_show
  ffffff8008403c78 T crypto_alloc_shash
  ffffff8008403cc8 T crypto_register_shash
  ffffff8008403d00 T crypto_unregister_shash
  ffffff8008403d30 T crypto_register_shashes
  ffffff8008403df8 T crypto_unregister_shashes
  ffffff8008403e90 T shash_register_instance
  ffffff8008403ed0 T shash_free_instance
  ffffff8008403f08 T crypto_init_shash_spawn
  ffffff8008403f58 T shash_attr_alg
  ffffff8008403fb0 T shash_ahash_finup
  ffffff8008404068 t shash_async_finup
  ffffff80084040b0 T shash_ahash_digest
  ffffff80084041e0 t shash_async_digest
  ...
  ```

- 使用一下宏定义导出符号

  ```c
  EXPORT_SYMBOL(module_symbol);
  //或
  EXPORT_GPL_SYMBOL(module_symbol);
  ```
  
  备注：EXPORT_SYMBOL将函数导出到内存的函数映射表中。

#### 6.模块描述 [可选]

模块编写者还可以为所编写的模块增加一些其它描述信息，如模块作者、模块本身的描述或者模块版本等 

```c
MODULE_AUTHOR("Abing <Linux@zlgmcu.com>");
MODULE_DESCRIPTION("ZHIYUAN ecm1352 beep Driver");
MODULE_VERSION("V1.00");
```

模块描述以及许可证声明一般放在文件末尾。 

#### 7.特殊宏定义

##### 1）MODULE_DEVICE_TABLE

- 公开供应商/设备id，在编译过程中会输出此信息到设备表。
- 插入设备时，内核会引用设备表，如果找到与添加的设备的设备/供应商ID匹配的条目，则会加载并初始化其模块。



### 三、向Linux内核添加新内核模块

#### 1.添加模块驱动文件

在linux/drivers/下新建目录hello，并且在hello/目录下新建hello.c、Makefile、Kconfig三个文件。

##### 1）内核模块程序hello.c

```c
/* hello world module */

#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>

static int __init hello_init(void)
{
  printk(KERN_INFO "Hello, I'm ready!\n");
  return 0;
}
static void __exit hello_exit(void)
{
  printk(KERN_INFO "I'll be leaving, bye!\n");
}
module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("michael");
MODULE_DESCRIPTION("hello world module");
```

- 内核通过 printk() 输出的信息具有日志级别，日志级别是通过在 printk() 输出的字符串前加一个带尖括号的整数来控制的，如 printk(“<6>Hello, world!/n”);。内核中共提供了八种不同的日志级别

  ```c
  // 在 linux/kernel.h 中有相应的宏对应
  #define KERN_EMERG    "<0>"    /* system is unusable */
  #define KERN_ALERT    "<1>"    /* action must be taken immediately */
  #define KERN_CRIT     "<2>"    /* critical conditions */
  #define KERN_ERR      "<3>"    /* error conditions */
  #define KERN_WARNING  "<4>"    /* warning conditions */
  #define KERN_NOTICE   "<5>"    /* normal but significant */
  #define KERN_INFO     "<6>"    /* informational */
  #define KERN_DEBUG    "<7>"    /* debug-level messages */
  ```

##### 2）Kconfig

```shell
menu "HELLO TEST Driver "
comment "HELLO TEST Driver Config"
 
config HELLO
	tristate "hello module test"
	default m
	help
	This is the hello test driver.
 
endmenu
```

- 在menuconfig的“driver”菜单下添加“HELLO TEST Driver”子菜单，并加入“HELLO”配置选项，选项默认为m。
- 保存menuconfig后，会在kernel根目录下的.config文件中生成“CONFIG_HELLO=m”，在编译的时候会添加到临时环境变量中。
- 通过make xxx_defconfig 命令会根据默认配置生成.config文件；make savedefconfig 会将.config生成defconfg文件。
  - cp defconfig arch/arm/configs/xxx_defconfig 保存

##### 3）Makefile

```makefile
obj-$(CONFIG_HELLO) += hello.o
```

**可用于动态模块外部编译的写法**

- 编译模块的内核配置必须与所运行内核的编译配置一样 。

  ```makefile
  ifneq ($(KERNELRELEASE),)
           obj-m += hello.o
  else
  KERNELDIR ?= /lib/modules/$(shell uname -r)/build  # 定义内核路径
  PWD := $(shell pwd)
  default:
          $(MAKE) -C $(KERNELDIR) M=$(PWD) modules   # 表示在当前目录下编译
  clean:
          rm -rf .*.cmd *.o *.mod.c *.ko .tmp_versions
  endif
  ```

  - KERNELRELEASE是在内核源码的顶层Makefile中定义的一个变量，在第一次读取执行此Makefile时，KERNELRELEASE没有被定义，所以make将读取执行else之后的内容。
  - 当从内核源码目录返回时，KERNELRELEASE已被定义，kbuild也被启动去解析kbuild语法的语句，make将继续读取else之前的内容，生成的目标模块名。



#### 2.修改上一级目录的Kconfig和Makefile

进入linux/drivers/

- 编辑Makefile，在后面添加一行：

  ```shell
  obj-$(CONFIG_HELLO) += hello/
  ```

- 编辑Kconfig，在后面添加一行：

  ```shell
  source "drivers/hello/Kconfig"
  ```

  - 注：某些内核版本需要同时在arch/arm/Kconfig中添加：source "drivers/hello/Kconfig"



#### 3.make menuconfig配置和编译

- 执行：*make menuconfig ARCH=arm*进入配置菜单
- 选择并进入：Device Drivers选项

![](https://img-blog.csdnimg.cn/20181103092424334.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTIyNDc0MTg=,size_16,color_FFFFFF,t_70)

- 进入 HELLO TEST Driver选项

  ![](https://img-blog.csdnimg.cn/20181103092457464.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTIyNDc0MTg=,size_16,color_FFFFFF,t_70)

  - 可以选择<m> <y> <n>，分别为编译成内核模块、编译进内核、不编译。

**如果选择编译成动态模块<m>**

- 编译内核过程中，会有如下输出：

  ```shell
  LD drivers/hello/built-in.o
  CC [M] drivers/hello/hello.o
  CC drivers/hello/hello.mod.o
  LD [M] drivers/hello/hello.ko
  ```

**如果选择编译进内核<y>**

- 编译内核过程中，会有如下输出：

  ```shell
  CC drivers/hello/hello.o
  LD drivers/hello/built-in.o
  ```



#### 4.动态模块加载和卸载 

加载模块的方法由两种

##### 1）手动加载（insmod / modprobe）

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

##### 2）内核自动加载（hot-plugging）

插入设备时，内核会引用设备表，如果找到与添加设备的设备/供应商ID匹配的条目，内核会执行insmod / modprobe加载模块。



检测模块加载与卸载工具

```shell
udevadm monitor
```



### 四、带参数的内核模块 

模块参数必须使用 module_param 宏来声明，通常放在文件头部。

module_param 需要 3个参数：变量名称、类型以及用于 sysfs 入口的访问掩码。 

```c
static int num = 5;
module_param(num, int, S_IRUGO);
```

- 内核模块支持的参数类型有： bool、 invbool、 charp、 int、 short、 long、 uint、 ushort和 ulong。 
- 访问掩码的值在<linux/stat.h>定义， S_IRUGO 表示任何人都可以读取该参数，但不能修改。 
- 支持传参的模块需包含 moduleparam.h 头文件。 



**能够接收参数的模块范例** 

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
MODULE_AUTHOR("luxiaodai");
MODULE_DESCRIPTION("this is my first module");
```

