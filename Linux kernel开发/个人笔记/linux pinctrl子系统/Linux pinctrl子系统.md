[TOC]

### 一、pinctrl子系统简介

​	在arm的各种soc芯片中，往往可以看到1个pin引脚，既可以作为GPIO，也可以作为spi、i2c、uart总线中的1根引脚，即该引脚是可以复用为不同功能的引脚。Linux内核引入的pinctrl子系统，是为了统一各soc厂商的pin脚管理。

#### 1.pinctrl子系统提供功能

- 管理系統中所有的可以控制的pin，在系統初始化的時候，枚舉所有可以控制的pin，並標識這些pin。

- 管理这些pin的复用（mux），通过pin function、pin group的搭配选择来管理一组的pin，定义该组pin为特定的功能。

- 配置每组pin内每个pin的特性，例如配置pin的上拉、下拉电阻，配置pin的driver strength等。



#### 2.pinctrl子系统的注册

芯片的pinctrl驱动通过postcore_initcall注册而不是module_init，因为pinctrl的注册要在其他驱动注册之前完成，各设备（如SOC片内的各个控制器）使用的引脚功能依赖于pinctrl子系统提供的引脚复用服务。

其他驱动的注册，设备驱动匹配后执行probe前，pinctrl子系统会自动配置设备需要的引脚复用。

![](https://img-blog.csdnimg.cn/2019050607272581.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1pIT05Ha3Vuamlh,size_16,color_FFFFFF,t_70)

注册完整流程：start_kernel -> rest_init -> kernel_init -> kernel_init_freeable -> do_basic_setup -> do_initcalls调用postcore_initcall。



#### 3.pinctrl 运行原理

- 读取dts: 先读入dts的pinmuxing节点的信息到map;
- dts的子节点的function 和 自定义function结构体的function的名字匹配, 得到自定义function结构体的下标, 放入Setting变量的func:
- 由自定义function结构体的下标, 得到自定义function结构体的group的名字和数量;
- 判断 dts的子节点的group 是否在自定义function结构体的group的名字里面, 如果是, 运行第5步, 否就运行第二步匹配dts下一个子节点的function;
- dts的子节点的group 和 自定义group结构体的group的名字匹配, 得到自定义group结构体的下标, 放入Setting变量的group;
- 通过Setting变量的func和group这两个下标调用struct pinmux_ops的enable回调函数. 哈哈, 络于可以设置寄存器了.



### 二、与GPIO子系统关系

​	pinctrl子系統把gpio一起管理起來，所有的gpio操作也需要透過pinctrl子系統來完成。如果一個pin已經被申請爲gpio，再通過pinctrl子系統申請爲某個function時就會返回錯誤。

![](https://pic1.xuehuaimg.com/proxy/csdn/https://img-blog.csdn.net/20180607165552719)





### 三、与设备树DTS的关系

在dts文件中可以在驱动节点中定义驱动需要用到的pin配置。

