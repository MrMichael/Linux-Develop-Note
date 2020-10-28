## 一、简介

RK平台USB控制器列表

![](https://upload-images.jianshu.io/upload_images/15877540-ca855556441326e6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



- RK3399支持两个Type-C USB3.0和两个USB 2.0 Host。两个Type-C USB 3.0控制器硬件都可以支持OTG(USB Peripheral和USB Host),并且向下兼容USB2.0/1.1/1.0。
- Type-C USB 3.0可以根据实际的应用需求,将物理接口简化设计为Type-A USB 3.0/2.0, Micro USB 3.0/2.0等多种接口类型，内核USB驱动已经兼容这几种不同类型的USB接口,只需要根据实际的硬件设计修改对应的板级DTS配置,就可以使能相应的USB接口。



RK3399 USB控制器&PHY连接示意图

![](https://upload-images.jianshu.io/upload_images/15877540-27cc68596212ceee.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- RK3399 SDK DTS的默认配置,支持Type-C0 USB 3.0 OTG功能, Type-C1 USB 3.0 Host功能。DTS的配置主要包括DWC3控制器、Type-C USB 3.0 PHY以及USB 2.0 PHY。





## 二、USB模块的DT开发

### 1.USB PHY DTS

- USB 2.0 PHY的配置主要包括PHY的时钟、中断配置和VBUS Supply的配置。
- USB 3.0 PHY的配置主要包括PHY的时钟、中断配置、Reset和Type-CPHY状态寄存器地址。



### 2.USB 2.0 Controller DTS

USB 2.0控制器主要包括EHCI、OHCI、OTG。其中EHCI和OHCI Rockchip采用Linux 内核Generic驱动, 开发时只需要对DT作相应配置,即可正常工作。

#### 1）USB 2.0 HOST Controller DTS

- 一个EHCI控制器的典型配置，主要包括register、interrupts、clocks的配置。

#### 2）USB 2.0 OTG Controller DTS

- 一个DWC2控制器的典型配置,主要包括register、interrupts、clocks的配置。
- DWC2相关的时钟,通常需要配置HCLK和PMUCLK两个时钟



### 3.USB 3.0 Controller DTS

#### 1）USB 3.0 HOST Controller DTS

- USB 3.0 HOST控制器为XHCI,集成于DWC3 OTG IP中,所以不用单独配置dts, 只需要配置DWC3,并且设置DWC3
  的dr_mode属性为dr_mode = "otg"或者dr_mode = "host",即可以enable XHCI控制器。

#### 2）USB 3.0 OTG Controller DTS