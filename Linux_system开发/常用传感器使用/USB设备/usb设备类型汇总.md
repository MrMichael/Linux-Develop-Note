[TOC]



> 参考：[usb wiki](https://zh.wikipedia.org/wiki/USB)、[USB](https://www.usb.org/defined-class-codes)



## 一、USB概述



### 1.USB 版本

![](https://upload-images.jianshu.io/upload_images/15877540-bdfecbedec4eef81.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



### 2.USB 接口

![](https://upload-images.jianshu.io/upload_images/15877540-9044ebdda00a17fe.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](http://wiki.csie.ncku.edu.tw/embedded/usb/pin.png)





### 3.USB Class Codes 

​	USB定义了设备类的类别码信息，它的功能包括：可以用来识别设备并且加载设备驱动。这种代码信息有包含Base Class（**[基类]**）、SubClass（**[子类]**）、Protocol（**[协议]**）一共占有3个字节。

[Base Class、SubClass与Protocol详细关系列表](https://www.usb.org/defined-class-codes)

![](https://upload-images.jianshu.io/upload_images/15877540-1f10023d615d8a62.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



### 4.USB封包格式

| 偏移量 |        類型        | 大小 |                              值                              |
| :----: | :----------------: | :--: | :----------------------------------------------------------: |
|   0    |    HeaderChksum    |  1   |         利用添加包頭進行效驗，不包括包頭本身的校驗。         |
|   1    |     HeaderSize     |  1   |                 包頭的大小，包括可用的字串。                 |
|   2    |     Signature      |  2   |                        資料值為0x1234                        |
|   4    |      VendorID      |  2   |                        USB提供商的ID                         |
|   6    |     ProductID      |  2   |                          USB產品ID                           |
|   8    |   ProductVersion   |  1   |                          產品版本號                          |
|   9    |  FirmwareVersion   |  1   |                          韌體版本號                          |
|   10   |      USB屬性       |  1   | USB Attribute: Bit 0：如果設為1，包頭包括以下三個字串：語言、製造商、產品字串；如果設為0，包頭不包括任何字串。 Bit 2：如果設為1，裝置自帶電源；如果設為0，無自帶電源。 Bit 3：如果設為1，裝置可以通過匯流排供電；如果設為0，無法通過匯流排供電。 Bits 1 and 4—7：保留。 |
|   11   |      最大電力      |  1   |              裝置需要的最大電力，以2mA為單位。               |
|   12   |      裝置屬性      |  1   | Device Attributes: Bit 0：如果設為1，CPU運行在24 MHz；如果設為0，CPU運行在12 MHz。 Bit 3：如果設為1，裝置的EEPROM可以支援400 MHz；如果設為0，不支援400 MHz。 Bits 1, 2 and 4 ... 7：保留。 |
|   13   |     WPageSize      |  1   |                    I2C的最大寫入頁面大小                     |
|   14   |      資料類型      |  1   | 該數值定義裝置是軟體EEPROM還是硬體EEPROM。0x02：硬體EEPROM 其它數值無效。 |
|   15   |     RpageSize      |  1   | I2C最大讀取頁面大小。如果值為0，整個負載大小由一個I2C讀取裝置讀取。 |
|   16   |    PayLoadSize     |  2   | 如果將EEPROM作為軟體EEPROM使用，表示軟體的大小；除此之外該值都是0。 |
|  0xxx  |  Language string   |  4   |       語言字串。以標準USB字串格式表示。（非必要欄位）        |
|  0xxx  | Manufacture string | ...  |      製造商字串。以標準USB字串格式表示。（非必要欄位）       |
|  0xxx  |   Product string   | ...  |       產品字串，以標準USB字串格式表示。（非必要欄位）        |
|  0xxx  |  Application Code  | ...  |     表示應用代碼。以標準USB字串格式表示。（非必要欄位）      |







## 二、常见usb设备类型

参考[ACM&ECM&NCM&EEM&RNDIS&RmNet介绍](https://wowothink.com/588ebc22/)

### 1.USB CDC设备

通用串行总线(USB)通信设备(Communication devices)的定义由三个类组成：

- 通信设备类(Communication Device Class, CDC)：设备级定义，被主机用于识别(确定)含有几种不同类型接口的通信设备；
- 通信接口类(Communication Interface Class)：定义了一种通用机制，该机制可被用来使能处于USB总线上的所有类型的通信服务，即USB通信设备的控制功能；
- 数据接口类(Data Interface Class)：定义了一种通用机制，当一种数据不符合任何类的要求时,该机制使这种数据传输能通过USB块传输或同步传输类型在USB总线上进行，即通过USB块传输或同步传输类型去实现任何类型的数据传输的机制。



#### 1）USB CDC ACM（虚拟串口）

- `CDC-ACM` (Abstract Control Model 抽象控制模型）允许任何通信设备提供串行通信接口（例如发送和接收AT命令的调制解调器设备）。该设备类型是在`PSTN(Public Switched Telephone Network)`中定义的。
- `CDC-ACM`驱动程序将USB设备作为虚拟调制解调器或虚拟COM端口暴露给操作系统。驱动程序可以通过ACM（通过不同通道分离数据和AT命令）或通过串行仿真（按原样传递AT命令和作为数据流的一部分）发送数据和AT命令。



#### 2）USB CDC ECM

`CDC-ECM`（Ethernet Networking Control Model 以太网网络控制模型）用于在设备和主机之间交换以太网帧数据。`CDC-ECM`设备的一般用例是LAN/WLAN的点对点以太网适配器。（获取的是局域网IP）



#### 3）USB CDC NCM

`CDC-NCM`（Network Control Model 网络控制模型）协议用于在设备和主机之间交换高速以太网帧数据。这些以太网帧可以传送通过通信网络传输的IPv4或IPv6数据报。`NCM`设备的一般用例是支持3.5G/4G网络的无线网络适配器，例如：HSPA +和LTE。**`NCM`是建立在`ECM`的基础上，进行改进以支持更高的数据速率，主要表现在**：

- 多个以太网帧可以聚合为单个USB传输；
- 为了最大限度地减少在USB设备中处理以太网帧时的开销，`CDC-NCM`可以按照最好的方式将以太网帧放到USB传输中。
- `CDC-ECM`专为USB full-speed设备而设计，尤其适用于支持DOCSIS 1.0电缆调制解调器。虽然`ECM`在功能上是完整的，但它在吞吐量或效率方面不能很好地扩展到更高的USB速度和更高的网络速度。`NCM`利用从`ECM`实施中获得的经验，并调整数据传输协议，使其更加高效。



#### 4）USB CDC EEM

`CDC-EEM`（Ethernet Emulation Model 以太网仿真模型）是一种通过USB总线以低成本和高效率传输以太网帧的规范。**与`CDC ECM`不同，`EEM`不会扩展USB总线上的接口，而是将USB总线视为移动以太网数据包的工具。`EEM`是较新的标准，比`ECM`稍微简单一些，可以获得更多的硬件支持。两者之间的差别是：**

- `ECM`将网络接口扩展到目标（例如USB电缆调制解调器）；
- `EEM`用于移动设备通过USB使用以太网与主机通信。

但是，对于Linux gadget，与主机的接口是相同的（usbX设备），因此差异很小。



#### 5）USB CDC OBEX

`USB CDC-OBEX`（Object Exchange 对象交换）符合`WMC`（Wireless Mobile Communication 无线移动通信）`OBEX`功能模型，支持USB上的`OBEX`应用程序。



#### 6）USB WMC

`USB WMC`（Wireless Mobile Communication 无线移动通信），可以理解为USB上网卡（连接移动通信网络），该模型包括以下内容：

![](https://ae01.alicdn.com/kf/H8b839dd02dc844afac1642a3e902a34e6.png)



### 2.RNDIS设备

- `RNDIS`（Remote Network Driver Interface Specification 远程网络驱动接口协议）**是Microsoft专有协议**，主要用于USB之上，在支持Microsoft RNDIS协议的Windows PC上提供类似CDC的通信功能。它提供了大多数Windows，Linux和FreeBSD操作系统版本的虚拟以太网链接。

- `NDIS`和`RNDIS`区别：`NDIS`是一种规范，定义了网络驱动接口的api。`RNDIS`是一种技术，是将TCP/IP封装在USB报文里，实现网络通信。

- `NDIS`和`PPP`区别：ppp通过pppd进行拨号，NDIS通过gobinet进行拨号。

- `RNDIS`的框架如下：

  ![](https://ae01.alicdn.com/kf/H0b614b3d2a7d47dbbaa759032689ebafo.png)



### 3.RmNet设备

`RmNet`是高通公司为其手机平台开发的*专有USB虚拟以太网框架*。 RmNet通过薄层协议（TLP）提供更高的吞吐量，并允许服务质量流量控制。

- `RmNet`和`CDC-ECM`区别：更像是两种拨号方式的区别，`RmNet`获取公网IP，`CCD-ECM`获取局域网IP。
- 在高通平台上，rmnet 也是属于`CDC-ECM`，他们具体的区别在于对于USB命令的封装以及使用的USB接口，端点定义方式不同。
- 如果是使用`RmNet`,那么发起data call是通过QMI工具发的QMI命令，QMI工具为QMICM，QMICM集成了QMI命令。
- 而通过标准的`CDC-ECM`发起data call，则是发送标准的`ECM`命令。
  - 如果是QMICM建立的data call，不走router的，所以它的IP地址获得的是公网IP。
  - 而通过标准的`CDC-ECM`建立的data call，是走router的，获得的IP地址是私有的IP如192.168开头。



### 4.HID设备

Human Interface Device的缩写，由其名称可以了解HID设备是直接与人交互的设备，例如键盘、鼠标与游戏杆等。不过HID设备并不一定要有人机接口，只要符合HID类别规范的设备都是HID设备。



### 5.Mass Storage设备

USB大容量存储设备是一个协议，允许一个[USB](https://baike.baidu.com/item/USB)接口的设备与主计算设备相连接，以便在两者之间传输文件。对于主计算设备来说，USB设备看起来就像一个移动硬盘，允许[拖放](https://baike.baidu.com/item/拖放)型文件传送。它实际上是由USB实施者论坛所通过许多通讯协议的汇总，这一标准提供了许多设备的界面。包括移动硬盘、[闪存盘](https://baike.baidu.com/item/闪存盘)、移动光学驱动器、[读卡器](https://baike.baidu.com/item/读卡器)、[数码相机](https://baike.baidu.com/item/数码相机)、数码音乐播放器、[PDA](https://baike.baidu.com/item/PDA)以及[手机](https://baike.baidu.com/item/手机)等等。