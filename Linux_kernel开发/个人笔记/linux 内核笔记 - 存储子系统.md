### 一、简介

​	Linux存储子系统的两个主要区域是文件系统层 （包括虚拟文件系统）和存储设备支持层。它们共同实现内核如何从数据中检索数据并将数据存储到辅助存储设备，如硬盘，磁带，光盘或闪存。

​	虚拟文件系统（Virtual File System, 简称 VFS）， 是 Linux 内核中的一个软件层，用于给用户空间的程序提供文件系统接口；同时，它也提供了内核中的一个 抽象功能，允许不同的文件系统共存。系统中所有的文件系统不但依赖 VFS 共存，而且也依靠 VFS 协同工作。

![](http://images.cnitblog.com/blog2015/710103/201504/231650051879292.png)

![](https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/IO_stack_of_the_Linux_kernel.svg/800px-IO_stack_of_the_Linux_kernel.svg.png)



### 二、虚拟文件系统

#### 1.VFS意义

- 向上，对应用层提供一个标准的文件操作接口；
- 对下，对文件系统提供一个标准的接口，以便其他操作系统的文件系统可以方便的移植到Linux上；
- VFS内部则通过一系列高效的管理机制，比如inode cache, dentry cache 以及文件系统的预读等技术，使得底层文件系统不需沉溺到复杂的内核操作，即可获得高性能；
- VFS把一些复杂的操作尽量抽象到VFS内部，使得底层文件系统实现更简单。

#### 2.VFS支持的文件系统

[文件系统列表]([https://zh.wikipedia.org/wiki/%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F%E5%88%97%E8%A1%A8](https://zh.wikipedia.org/wiki/文件系统列表))

- 磁盘文件系统
- 网络文件系统
- 特殊文件系统

![](https://upload-images.jianshu.io/upload_images/15877540-2f01cf2f2bd3360c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)