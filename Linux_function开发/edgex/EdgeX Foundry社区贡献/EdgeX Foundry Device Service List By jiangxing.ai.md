[TOC]



## 1. Device-service list for go by jiangxing.ai

| Micro Service                                                | Description                                                  | Interface       | Protocol                                     | Privacy level |
| ------------------------------------------------------------ | ------------------------------------------------------------ | --------------- | -------------------------------------------- | ------------- |
| [device-hts40l](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-hts40l) | This edgex device service is developed for the temperature and humidity sensor(specific to HTS40L).  It provides REST API interfaces to obtain temperature and humidity data. | RS485           | Modbus-RTU                                   | Public        |
| [device-ttyusb](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-ttyusb) | This edgex device service is developed for universal serial device, such as USB to TTL serial port, rs232 interface and rs485 interface device.  It provides REST API interfaces to communicate with serial sensors or configure them. | TTL/RS232/RS485 | uart                                         | Public        |
| [device-plc](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-plc) | This edgex device service is developed for PLC controller of Siemens series. It provides REST API interfaces to perform remote connections, read and write registers, close connections, etc. | Ethernet port   | Siemens S7 protocol(based on Snap7 Lib)、TCP | Public        |
| [device-mpu6050](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-mpu6050) | This edgex device service is developed for the Six-axis sensor(specific to GY25Z-MPU6050).  It provides REST API interfaces to get data from gyroscope and acceleration sensor. | TTL             | uart                                         | Public        |
| [device-pm25](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-pm25) | This edgex device service is developed for the PM2.5 sensor(specific to ZPH02).  It provides REST API interfaces to get data from PM2.5 sensor. | TTL             | uart                                         | Public        |
| [device-relay](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-relay) | This edgex device service is developed for the one button bistable relay device.  It provides REST API interfaces to control the connection and disconnection of the relay. | GPIO            | IO                                           | Public        |
| [device-infrared](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-infrared) | This edgex device service is developed for the infrared obstacle avoidance sensor.  It provides REST API interfaces to know whether the sensor detects an obstacle. | GPIO            | IO                                           | Public        |
| [device-hid-buzzer](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-hid-buzzer) | This edgex device service is developed for the usb-hid buzzer device.  It provides REST API interfaces to control the on and off of the buzzer. | USB             | usb-hid                                      | Public        |
| [device-light-sensor](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-light-sensor) | This edgex device service is developed for the light intensity sensor(specific to MAX44009).  It provides REST API interfaces to obtain the data of light intensity. | I2C             | I2C                                          | Public        |
| [device-buzzer](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-buzzer) | This edgex device service is developed for the active buzzer device.  It provides REST API interfaces to control the on and off of the buzzer. | GPIO            | IO                                           | Public        |
| [device-temperature-sensor](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-temperature-sensor) | This edgex device service is developed for the temperature sensor(specific to DS18B20).  It provides REST API interfaces to obtain temperature data. | GPIO            | 1-wire                                       | Public        |
| [device-angle-sensor](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-angle-sensor) | This edgex device service is developed for the tilt sensor(specific to HVS120T).  It provides REST API interfaces to obtain the inclination data of sensor. | RS485           | uart                                         | Public        |
| [device-gps](http://gitlab.jiangxingai.com/applications/edgex/device-service/device-gps) | This edgex device service is developed for the GPS+BDS Beidou Dual-Mode module sensor(specific to ATGM336H).  It provides REST API interfaces to regularly read GPS NEMA information and convert it to GPS coordinate information. | TTL             | uart、NEMA                                   | Public        |



## 2. Device detail

### 1) Passive Buzzer Alarm Module

![](https://images-na.ssl-images-amazon.com/images/I/61qfVxM29TL._AC_SL1100_.jpg)

- Function: Provides a buzzer sound and used for alarm or reminder.

- Vendor: Commonly used sensors in electronic malls.
  
  - [amazon link](https://www.amazon.com/-/zh_TW/Willwin-3-3-5V-Passive-Trigger-Arduino/dp/B0777P6FN5/ref=sr_1_6?dchild=1&keywords=active+buzzer+module&qid=1598260287&sr=8-6)
- Characteristics:
  - Voltage : DC 3.3-5V
  - Materials : PCB
  - PCB Size : 3.1 x 1.3cm/1.2" x 0.51"(L*W); 
- Physical interface: GPIO*1, Input
- Driver protocol: IO

- REST API Description

  | Method | Core Command | Description                     | Response |
  | ------ | ------------ | ------------------------------- | -------- |
  | put    | open         | The buzzer keeps beeping        | 200 ok   |
  | put    | close        | The buzzer stops beeping        | 200 ok   |
  | put    | beep         | The buzzer beeps for one second | 200 ok   |



### 2) GP-02 GPS + BDS Compass ATGM336H Module

![](https://images-na.ssl-images-amazon.com/images/I/51gVCSy8jnL._SL1000_.jpg)

- Function: Support the single-system positioning of BDS/GPS/GLONASS satellite navigation system and the receiver module of any combination of multi-system joint positioning.

- Vendor: [icofchina](http://www.icofchina.com/)
  
  - [amazon link](https://www.amazon.com/-/zh_TW/dp/B07YZVCXCH/ref=sr_1_2?dchild=1&keywords=ATGM336H&qid=1598261693&sr=8-2)
- Characteristics:
  - Supply Voltage:2.7~3.6V
  - Dissipation Power:25mA
  - Materials : PCB
  - Built-in antenna short circuit protection
  - Number of channels: 32
  - Positioning accuracy: 2.5m (CEP50, open area)
  - Cold start capture sensitivity: -148dBm
  - Tracking sensitivity: -162dBm
- Physical interface: TTL
- Driver protocol: UART

- REST API Description

  | Method | Core Command | Description              | Response                                                     |
  | ------ | ------------ | ------------------------ | ------------------------------------------------------------ |
  | get    | gps          | Get location information | "{\"Altitude\":51.5,\"Latitude\":\"22° 33' 6.100200\\\"\",\"Longitude\":\"113° 52' 55.000200\\\"\",\"NumSatellites\":7,\"Time\":\"07:40:10.0000\"}" |

  

### 3) Infrared Barrier Module 

![](https://images-na.ssl-images-amazon.com/images/I/616aMVbntrL._AC_SL1100_.jpg)

- Function: Determine whether there is an obstacle ahead by infrared. It can be widely used in robot obstacle avoidance, obstacle avoidance car, line counting, and black and white online tracking and so on.

- Vendor: Commonly used sensors in electronic malls.
  
  - [amazon link](https://www.amazon.com/-/zh_TW/Willwin-Infrared-Obstacle-Avoidance-Intelligent/dp/B0776RCLH6/ref=sr_1_1?dchild=1&keywords=Infrared+barrier+module&qid=1598263202&sr=8-1)
- Characteristics:
  - Voltage : DC 3-5V
  - Materials : PCB
  - effective distance: 2 ~ 30cm
  - effective angle: 35°
- Physical interface: GPIO*1, Output
- Driver protocol: IO

- REST API Description

  | Method | Core Command | Description                                  | Response          |
  | ------ | ------------ | -------------------------------------------- | ----------------- |
  | get    | check        | Determine whether there is an obstacle ahead | "true" or "false" |



### 4) GY-49 MAX44009 Ambient Light Sensor Module

![](https://images-na.ssl-images-amazon.com/images/I/31SRTbPQFBL.jpg)

- Function: Used to detect ambient light intensity.

- Vendor: Commonly used sensors in electronic malls.
  
  - [amazon link](https://www.amazon.com/-/zh_TW/dp/B07ZR5NZZB/ref=sr_1_4?dchild=1&keywords=max44009&qid=1598263863&sr=8-4)
- Characteristics:
  - Voltage : DC 1.7V to 3.6V
  - Operating Current: 0.65μA
  - Materials : PCB
  - Temperature Range: -40°C to +85°C
  - effective angle: 35°
  - dynamic range:  0.045 to 188,000 Lux 
- Physical interface: I2C
- Driver protocol: I2C Slave

- REST API Description

  | Method | Core Command | Description                     | Response         |
  | ------ | ------------ | ------------------------------- | ---------------- |
  | get    | light        | Get the ambient light intensity | "383.040009 lux" |



### 5) GY-25Z Serial Port MPU6050 Module 

![](https://images-na.ssl-images-amazon.com/images/I/41%2BOMv3TQbL.jpg)

- Function: Used to get data of 6-axis sensor(Gyroscope, acceleration and angular tilt)

- Vendor: Commonly used sensors in electronic malls.
  
  - [amazon link](https://www.amazon.com/-/zh_TW/dp/B07Q3LVB1S/ref=sr_1_3?dchild=1&keywords=GY25Z&qid=1598264543&sr=8-3)
- Characteristics:
  - Voltage : DC 3-5V
  - Operating Current: 15mA
  - Measuring range: -180 degrees to 180 degrees
  - Repeatability: 1 degree
  - Operating temperature: -20 degrees Celsius ~ 85 degrees Celsius
  - Response frequency: 100HZ (115200bps)
- Physical interface: TTL
- Driver protocol: UART

- REST API Description

  | Method | Core Command | Description               | Response                                            |
  | ------ | ------------ | ------------------------- | --------------------------------------------------- |
  | get    | mpu6050      | Get data of 6-axis sensor | "{\"pitch\":1.483,\"roll\":-10.561,\"yaw\":-8.887}" |



### 6) ZPH02-PM2.5 Particles Sensor

![](https://ce8dc832c.cloudimg.io/fit/640x480/n@0c8484bc4e266ca6e17eb670e2f4fa0a8d4ff73d/_cdn_/5A/A6/90/00/0/617125_1.jpg?mark_url=_tme-wrk_%2Ftme_new.png&mark_pos=center&mark_size=100pp)

- Function: This sensor integrates infrared PM2.5 detection technology, using particle counting principle to detect PM2.5 in the environment.

- Vendor: [WINSEN](https://www.winsen-sensor.com/sensors/dust-sensor/zph02.html)
  
  - [amazon link](https://www.amazon.com/-/zh_TW/Particles-Detection-Install-Sensitivity-Refresher/dp/B07VKDP97F/ref=sr_1_1?dchild=1&keywords=ZPH02&qid=1598265237&sr=8-1)
- Characteristics:
  - Voltage : DC 5V
  - Operating Current: 90mA
  - particles diameter:  ≥1μm
  - Repeatability: 1 degree
  - Preheat time: about 1 minute
  - Operating temperature: 0 degrees Celsius ~ 50 degrees Celsius
- Physical interface: TTL, EH2.54-5P socket
- Driver protocol: UART

- REST API Description

  | Method | Core Command | Description     | Response |
  | ------ | ------------ | --------------- | -------- |
  | get    | pm25         | Get PM2.5 value | "10"     |



### 7) Bond Button Bistable Relay Module

![](https://images-na.ssl-images-amazon.com/images/I/61xpf98P46L._AC_SL1000_.jpg)

- Function: Used to control the connection status of the secondary circuit(open circuit or close circuit).

- Vendor: Commonly used sensors in electronic malls.
  
  - [amazon link](https://www.amazon.com/HiLetgo-Channel-Latching-Bistable-Control/dp/B00LW2VLS0/ref=sr_1_1_sspa?dchild=1&keywords=One+Button+Bistable+Relay&qid=1598266145&sr=8-1-spons&psc=1&spLa=ZW5jcnlwdGVkUXVhbGlmaWVyPUE1WEhaTk9SRktXV0gmZW5jcnlwdGVkSWQ9QTA3NTQzNTNNM1oxUkxCSFdEQ0smZW5jcnlwdGVkQWRJZD1BMDE0NjQyM1FONzcxTUZIOTRGRCZ3aWRnZXROYW1lPXNwX2F0ZiZhY3Rpb249Y2xpY2tSZWRpcmVjdCZkb05vdExvZ0NsaWNrPXRydWU=)
- Characteristics:
  - Voltage : DC 5V
  - Relay secondary output end bears current: < 10A
- Physical interface: GPIO*1
- Driver protocol: IO

- REST API Description

  | Method | Core Command | Description            | Response |
  | ------ | ------------ | ---------------------- | -------- |
  | put    | open         | Set the relay to close | 200 ok   |
  | put    | close        | Set relay open         | 200 ok   |



### 8) DS18B20 Temperature Sensor Module

![](https://images-na.ssl-images-amazon.com/images/I/51dd4OOskkL.jpg)

- Function: Used to control the connection status of the secondary circuit(open circuit or close circuit).

- Vendor: Commonly used sensors in electronic malls.
  
  - [amazon link](https://www.amazon.com/-/zh_TW/ARCELI-DS18B20-Temperature-Electronic-Building/dp/B07DN3R1YW/ref=sr_1_4?dchild=1&keywords=DS18B20+module&qid=1598267300&sr=8-4)
- Characteristics:
  - Voltage : DC 3V～5.5V
  - Temperature range: -55°C～+125°C(
- Physical interface: GPIO*1
- Driver protocol: 1-wire
  
- Dependence: Pre-installed 1-wire driver 
  
- REST API Description

  | Method | Core Command | Description                                | Response |
  | ------ | ------------ | ------------------------------------------ | -------- |
  | get    | temperature  | Get the ambient temperature, unit 0.001 °C | "27000"  |



### 9) Universal serial port for linux

![](https://images-na.ssl-images-amazon.com/images/I/61NuCYQ5E%2BL._AC_SL1001_.jpg)

- Function: You can send data, receive data and modify the serial port configuration to any serial device for linux system, such as chip serial port, USB to TTL module, RS232 module and RS485 module.

- Vendor: Commonly used sensors in electronic malls.
  
  - [amazon link](https://www.amazon.com/-/zh_TW/DSD-TECH-SH-U09C2-Debugging-Programming/dp/B07TXVRQ7V/ref=sr_1_3?dchild=1&keywords=usb+to+ttl&qid=1598269560&sr=8-3)
- Characteristics:
  
  - Universal serial port
- Physical interface: TTL, RS232, RS485, USB to TTL
- Driver protocol: UART

- REST API Description

  | Method | Core Command | parameters                         | Description                                                  | Response                                             |
  | ------ | ------------ | ---------------------------------- | ------------------------------------------------------------ | ---------------------------------------------------- |
  | get    | gethex       |                                    | Get serial device data, output in hex string format          | "{"rx utc":1588848050,"rxbuf hex":"32333437383536"}" |
  | get    | getstring    |                                    | Get serial device data, output in ascii string format        | "{"rx utc":1588848340,"rxbuf string":"aadd33"}"      |
  | put    | sendhex      | {"sendhex":<txbuf>}                | Send data to the serial device, input in hex string format   | 200 ok                                               |
  | put    | sendstring   | {"sendstring":<txbuf>}             | Send data to the serial device, input in ascii string format | 200 ok                                               |
  | get    | uartconfig   |                                    | Get serial port configuration parameters                     | "{"baud":"9600","device path":"/dev/ttyUSB5"}"       |
  | put    | uartconfig   | {"path":<path>,<br/>"baud":<baud>} | Configure serial port parameters                             | 200 ok                                               |



### 10) Device-UART-GO

- Function: 

  - This Device Service is a reference example of a Device Service developed with **[Go Device Service SDK](https://github.com/edgexfoundry/device-sdk-go)**.
  - It is developed for universal serial device, such as USB to TTL serial port, rs232 interface and rs485 interface device.  It provides REST API interfaces to communicate with serial sensors or configure them.

- Characteristics:

  - Universal serial port

- Physical interface: TTL, RS232, RS485, USB to TTL

- Driver protocol: UART

- Usage

  - This Device Service have to run with other EdgeX Core Services, such as Core Metadata, Core Data, and Core Command.
  - After starting the service, the linux uart device will be opened and configured(defalut: /dev/ttyUSB0 with 115200 bps). User can choose another uart device by sending "uartconfig" command.
  - When uart device is opend,  the data sent from another sensors will be stored and they can be read by "gethex" or "getstring" command. User can also sends down link data to those sensors by "sendhex" or  "sendstring" command.

- REST API Description

  | Method | Core Command | parameters                         | Description                                                  | Response                                       |
  | ------ | ------------ | ---------------------------------- | ------------------------------------------------------------ | ---------------------------------------------- |
  | get    | gethex       |                                    | Get serial device data, output in hex string format          | "{"rxbuf hex":"32333437383536"}"               |
  | get    | getstring    |                                    | Get serial device data, output in ascii string format        | "{"rxbuf string":"aadd33"}"                    |
  | put    | sendhex      | {"sendhex":<txbuf>}                | Send data to the serial device, input in hex string format   | 200 ok                                         |
  | put    | sendstring   | {"sendstring":<txbuf>}             | Send data to the serial device, input in ascii string format | 200 ok                                         |
  | get    | uartconfig   |                                    | Get serial port configuration parameters                     | "{"baud":"9600","device path":"/dev/ttyUSB5"}" |
  | put    | uartconfig   | {"path":<path>,<br/>"baud":<baud>} | Configure serial port parameters                             | 200 ok                                         |



### 11) Device-GPIO-GO

- Function: 

  - This Device Service is a reference example of a Device Service developed with **[Go Device Service SDK](https://github.com/edgexfoundry/device-sdk-go)**.
  - It is developed to control the system gpio through the following functions. For example, export or unexport the gpio, set gpio direction to output or input mode, set the gpio output status and get gpio status.

- Physical interface: system gpio (/sys/class/gpio)

- Driver protocol: IO

- Usage

  - This Device Service have to run with other EdgeX Core Services, such as Core Metadata, Core Data, and Core Command.
  - After starting the service, user can use "exportgpio" command to export a system gpio which comes from the path "/sys/class/gpio". Then configure the gpio by sending "gpiodirection" or "gpiovalue" command, and check it's configuration by getting them.

- REST API Description

  | Method | Core Command  | parameters                | Description                                                  | Response                             |
  | ------ | ------------- | ------------------------- | ------------------------------------------------------------ | ------------------------------------ |
  | put    | exportgpio    | {"export":<gpionum>}      | Export a gpio from "/sys/class/gpio"<br><gpionum>: int, gpio number | 200 ok                               |
  | put    | unexportgpio  | {"unexport":<gpionum>}    | Export a gpio from "/sys/class/gpio"<br/><gpionum>: int, gpio number | 200 ok                               |
  | put    | gpiodirection | {"direction":<direction>} | Set direction for the exported gpio<br/><direction>: string, "in" or "out" | 200 ok                               |
  | get    | gpiodirection |                           | Get direction of the exported gpio                           | "{\"direction\":\"in\",\"gpio\":65}" |
  | put    | gpiovalue     | {"value":<value>}         | Set value for the exported gpio<br/><value>: int, 1 or 0     | 200 ok                               |
  | get    | gpiovalue     |                           | Get value of the exported gpio                               | "{\"gpio\":65,\"value\":1}"          |











