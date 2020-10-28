

### 1. official device-service for go

| Micro Service                                                | Description                                                  |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| [device-modbus-go](https://github.com/edgexfoundry/device-modbus-go) | 用于将Modbus设备连接到EdgeX                                  |
| [device-mqtt-go](https://github.com/edgexfoundry/device-mqtt-go) | 用于将MQTT主题连接到EdgeX，就像设备/传感器订阅源一样。       |
| [device-camera-go](https://github.com/edgexfoundry/device-camera-go) | 用于对ONVIF兼容的摄像头进行控制和通信，可通过EdgeX部署中的http访问这些摄像头 |
| [device-virtual-go](https://github.com/edgexfoundry/device-virtual-go) | 提供布尔、整型、无符号整型、浮点型、二进制类型数据的随机值生成器，用于基础测试 |
| [device-snmp-go](https://github.com/edgexfoundry/device-snmp-go) | 通用SNMP设备服务，包括一个网络交换设备驱动程序的示例，可通过配置方便地访问TrendNet TEG-082WS 10端口交换机 |
| [device-rest-go](https://github.com/edgexfoundry/device-rest-go) | 此设备服务为第三方应用程序提供了简便的方法，以通过REST协议将数据推送到EdgeX。 |



### 2. jx device-service for go

| Micro Service                                                | Description                                                  | Interface          | Protocol                         | Privacy level |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------ | -------------------------------- | ------------- |
| [device-hts40l](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-hts40l) | HTS40L温湿度传感器设备服务，提供REST API接口获取获取其温度和湿度数据 | RS485              | Modbus-RTU                       | Public        |
| [device-ttyusb](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-ttyusb) | 针对usb转tty串口、rs232接口、rs485接口而适配的通用串口设备微服务，通过REST API接口可以对任意串口设备进行发送数据、接收数据、修改串口配置 | TTL/RS232/RS485    | uart                             | Public        |
| [device-plc](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-plc) | 西门子PLC控制器设备服务，提供REST API接口对控制器进行远程连接、读写寄存器、关闭连接等操作 | Ethernet port      | 西门子S7协议(基于Snap7 Lib)、TCP | Public        |
| [device-mpu6050](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-mpu6050) | GY25Z-MPU6050六轴传感器设备服务，提供REST API接口获取陀螺仪、加速度传感器的数据 | TTL                | uart                             | Public        |
| [device-pm25](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-pm25) | ZPH02粉尘传感器设备服务，提供REST API接口获取PM2.5值         | TTL                | uart                             | Public        |
| [device-relay](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-relay) | 单键双稳态继电器设备服务，提供REST API接口控制继电器的连接和断开 | GPIO               | IO                               | Public        |
| [device-infrared](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-infrared) | 红外避障模块设备服务，提供REST API接口获知是否存在障碍物     | GPIO               | IO                               | Public        |
| [device-hid-buzzer](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-hid-buzzer) | usb-hid蜂鸣器设备服务，提供REST API接口控制蜂鸣器的开启和关闭 | USB                | usb-hid                          | Public        |
| [device-light-sensor](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-light-sensor) | MAX44009光照强度传感器设备服务，提供REST API接口获取光照强度信息 | I2C                | I2C                              | Public        |
| [device-buzzer](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-buzzer) | 有源蜂鸣器模块设备服务，提供REST API接口控制蜂鸣器的开启和关闭 | GPIO               | IO                               | Public        |
| [device-temperature-sensor](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-temperature-sensor) | DS18B20测温模块设备服务，提供REST API接口获取当前温度        | GPIO               | 1-wire                           | Public        |
| [device-angle-sensor](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-angle-sensor) | HVS120T倾角传感器设备服务，提供REST API接口获取当前角度      | RS485              | uart                             | Public        |
| [device-gps](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-gps) | ATGM336H GPS 北斗双模模块设备服务，定期读取GPS NEMA信息，并转为GPS坐标信息 | TTL                | uart、NEMA                       | Public        |
|                                                              |                                                              |                    |                                  |               |
|                                                              |                                                              |                    |                                  |               |
| [device-ivs101a](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-ivs101a) | ivs101a BLE智能振动分析仪设备服务，提供REST API接口扫描周边ivs101a蓝牙设备、获取蓝牙设备的mac地址和广播名称以及发送特殊命令到蓝牙服务的特征值等功能。 | BLE                | BLE 4.0、BLE 4.2                 | Internal      |
| [device-433_wave_sensor](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-433_wave_sensor) | 433M(FSK)舞动传感器设备服务，用于接收并解析传感器数据（如温度值、电池电压、舞动频率、顺线幅值），并提供REST API接口获取解析数据 | TTL                | uart                             | Internal      |
| [device-lora_wave_sensor](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-lora_wave_sensor) | lora 舞动传感器设备服务，用于接收并解析传感器数据（如温度值、电池电压、舞动频率、顺线幅值），并提供REST API接口获取解析数据 | TTL                | uart                             | Internal      |
| [device-rfid](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-rfid) | RFID传感器设备服务，提供REST API接口读取RFID的信息           | I2C                | I2C                              | Internal      |
| [device-dsms](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-dsms) | DSMS 司机驾驶检测装置设备服务，提供REST API接口获取装置告警信息以及下发语音告警 | TTL                | uart、RabbitMQ                   | Internal      |
| [device-cameras](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-cameras) | 摄像头统一设备服务，提供usb或ip摄像头的拍照、推流、onvif控制等功能 | USB、Ethernet port | RTSP、Onvif                      | Internal      |
| [device-uart-lcd](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-uart-lcd) | uart串口智能屏设备服务，提供REST API修改智能屏的数据或获取其状态 | TTL                | uart                             | Internal      |



















