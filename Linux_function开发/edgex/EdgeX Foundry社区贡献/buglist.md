

#### 1.Device service docker container REST API interface access failed

- EdgeX Foundry environment

  - [docker-compose-geneva-redis-arm64.yml](https://github.com/edgexfoundry/developer-scripts/blob/master/releases/geneva/compose-files/docker-compose-geneva-redis-arm64.yml)

- Problem:

  - The docker-device-gpio-go container is running normally in EdgeX Foundry environment and  we can find device-gpio in consul. However, it fails to access the REST API interface of device-gpio-go through the curl command on the host. The error is as follows.

    ```shell
    Get http://172.17.0.1:49960/api/v1/device/0c6976ca-5461-4657-bbc4-3e092858f6a1/gpiovalue?: read tcp 192.168.112.4:57180->172.17.0.1:49960: read: connection reset by peer
    ```




自我介绍

- I am the software engineer from jiangixngai  team. and I am responsible for the construction of our  device services



今天主题

1.介绍上周五提交的两个device service

- on the last Friday, we make a  contribution for two device service, they are device-gpio-go and device-uart-go.  so firstly, today let's spend a little time to introduce those deivce services and we can have a discussion about them.  
  - the first one is device-gpio-go, it is a reference example that developed with Go Device Service SDK.
    - The main function of the device service is providing a way to access the system gpio under the path of  /sys/class/gpio. for example, export or unexport a gpio by "exportgpio" or "unexportgpio" commands ; set or get the gpio direction or value of the exported gpio by "gpiodirection" or "gpiovalue" command; 
    - Because there are many sensors are controlled based on the gpio interface. So this device service can also directly operate them
  - the second one is device-uart-go, it is also a reference example that developed with Go Device Service SDK.
    - It is developed for universal serial device, such as USB to TTL serial port, rs232 interface and rs485 interface device. and It provides REST API interfaces to communicate with serial sensors or configure them.
    - for example, we can use the "gethex" or "getstring" command to read the data got from other sensor. then use "sendhex" or "snedstring" command to send data back. if we wanna to change the rate of uart device, we can use "uartconfig" command to configure it



2.简单介绍以这两个device-service为基础而开发的具体传感器的设备微服务。

- Base on those two device-services，we use the following sensors as examples to develop specific device services，they are：
  - Buzzer alarm module, it is base on the device-gpio-go project
  - 





3.目前项目的进展及遇到的一些问题

- There are some question we meet. the first one is   The docker-device-gpio-go container