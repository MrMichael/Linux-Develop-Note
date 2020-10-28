[BlueZ](http://www.bluez.org/)是Linux中最常用的蓝牙协议栈。hciconfig、hcitool、gatttool都是BlueZ下的工具。



### 1.启动蓝牙适配器与搜索蓝牙

```shell
# 查看蓝牙适配器
$ hciconfig
hci0:	Type: Primary  Bus: USB
	BD Address: 20:32:33:3C:2B:27  ACL MTU: 1021:6  SCO MTU: 255:12
	UP RUNNING 
	RX bytes:4404 acl:19 sco:0 events:310 errors:0
	TX bytes:29537 acl:19 sco:0 commands:246 errors:0
# 开启蓝牙适配器
$ sudo hciconfig hci0 up
#关闭蓝牙适配器
$ sudo  hciconfig hci0 down

# 搜索普通蓝牙
$ hcitool scan
# 搜索BLE蓝牙
$ sudo hcitool lescan
LE Scan ...
55:D8:80:D4:47:8D (unknown)
72:AB:2E:49:75:93 (unknown)
DD:0D:30:00:18:9D (unknown)
5C:90:AD:B6:40:9C (unknown)
64:BB:A7:4B:B4:B2 (unknown)
35:1A:4A:72:C8:9A (unknown)
1C:99:C7:EE:32:FF (unknown)
77:3E:2C:8E:F7:F8 (unknown)
4E:BC:B7:7F:E9:CE (unknown)
DD:0D:30:00:18:9D FSC-BT901-LE
F4:52:53:51:F5:39 iVS101 F539 
77:3E:2C:8E:F7:F8 (unknown)
F4:52:53:51:F5:39 (unknown)

# 使用blescan搜索
sudo apt-get install libglib2.0-dev
sudo pip install bluepy
sudo blescan
Scanning for devices...
    Device (new): 7d:5a:28:10:e8:2a (random), -74 dBm 
	Flags: <06>
	Manufacturer: <4c0010054b1c52787d>
    Device (new): ea:b6:0b:b3:17:d3 (public), -60 dBm 
	Flags: <02>
	Incomplete 16b Services: <0000fff0-0000-1000-8000-00805f9b34fb>
	Complete Local Name: 'CDEBYTE_BLE'
    Device (new): 5a:6e:64:1c:1d:db (random), -73 dBm (not connectable)
	Manufacturer: <0600010920025604764baf060dcb31a9c15ba489c14dd5c712617014f5>
    Device (new): 07:cb:91:af:81:3d (random), -69 dBm (not connectable)
	Manufacturer: <060001092002794ecc2fafae2e26175cba8311a5d2e53da7c38e6a0b90>
    Device (new): 2b:15:2b:c9:ff:7d (random), -69 dBm (not connectable)
	Manufacturer: <0600010920026a02e81611e0afc71f870d80b5a27bfad7a0d7074e85c0>
    Device (new): 72:47:41:e2:e2:57 (random), -93 dBm 
	Flags: <1a>
	Tx Power: <0c>
	Manufacturer: <4c001006031e09a2d6dd>
    Device (new): 5b:4a:cc:f0:15:80 (random), -67 dBm (not connectable)
	Manufacturer: <4c000719010e2023768f010004d2bfafe26e62c4eed123ee504e527a0c>
	Device (new): 6b:2a:27:4b:43:a6 (random), -54 dBm 
	Flags: <1a>
	Tx Power: <0c>
	Complete Local Name: 'iVS101 F539 '
	Manufacturer: <4c001006031af7153816>
    Device (new): 46:03:fa:ab:4c:41 (random), -84 dBm 
	Flags: <06>
	Manufacturer: <4c001005471c37136d>
    Device (new): 7f:aa:38:bf:05:11 (random), -92 dBm 
	Flags: <1a>
	Tx Power: <0c>
	Manufacturer: <4c001005411cc8b34d>
    Device (new): 1d:e1:6d:a8:15:db (random), -65 dBm (not connectable)
	Manufacturer: <0600010920020f2636d257263e0f6ce4dfe67621a18c0828265b0f7c6d>
    Device (new): 73:38:2a:71:83:1a (random), -94 dBm 
	Flags: <1a>
	Tx Power: <0c>
	Manufacturer: <4c001005541cf0dfc5>
    Device (new): 51:a5:80:6b:f0:b7 (random), -68 dBm 
	Flags: <1a>
	Tx Power: <0c>
	Manufacturer: <4c001006561ef95caa03>
    Device (new): 46:84:15:87:3b:60 (random), -89 dBm 
	Flags: <1a>
	Tx Power: <18>
	Manufacturer: <4c0010050198649950>
    Device (new): 45:de:a0:17:ef:20 (random), -94 dBm 
	Flags: <06>
	Manufacturer: <4c000c0e086cb7e7ef2f3dbaeb5c37a12012>
    Device (new): f0:18:98: :32:95 (public), -95 dBm 
	Flags: <06>
	Manufacturer: <4c0010020b00>
    Device (new): f4:52:53:51:f5:39 (random), -60 dBm 
	Complete Local Name: 'iVS101 F539 '
	Complete 128b Services: <6e400001-b5a3-f393-e0a9-e50e24dcca9e>
	Manufacturer: <1131f4525351f539>
	Flags: <06>
	Device (new): 59:24:82:df:3e:5d (random), -51 dBm (not connectable)
	Manufacturer: <4c00071901052000f58f050100c8e02cc72a9c1234e863dbaa6a817e89>
```



### 2.使用gatttool与BLE设备通讯

```shell
# 与BLE设备交互式通讯
$ sudo gatttool -t random -b F4:52:53:51:F5:39 -I
[F4:52:53:51:F5:39][LE]> help 
help                                           Show this help
exit                                           Exit interactive mode
quit                                           Exit interactive mode
connect         [address [address type]]       Connect to a remote device
disconnect                                     Disconnect from a remote device
primary         [UUID]                         Primary Service Discovery
included        [start hnd [end hnd]]          Find Included Services
characteristics [start hnd [end hnd [UUID]]]   Characteristics Discovery
char-desc       [start hnd] [end hnd]          Characteristics Descriptor Discovery
char-read-hnd   <handle>                       Characteristics Value/Descriptor Read by handle
char-read-uuid  <UUID> [start hnd] [end hnd]   Characteristics Value/Descriptor Read by UUID
char-write-req  <handle> <new value>           Characteristic Value Write (Write Request)
char-write-cmd  <handle> <new value>           Characteristic Value Write (No response)
sec-level       [low | medium | high]          Set security level. Default: low
mtu             <value>                        Exchange MTU for GATT/ATT

# 连接BLE
[F4:52:53:51:F5:39][LE]> connect
Connection successful

# 寻找BLE设备中可用的服务
[F4:52:53:51:F5:39][LE]> primary
#attr handle是服务的句柄，uuid是服务的类型标识
attr handle: 0x0001, end grp handle: 0x0007 uuid: 00001800-0000-1000-8000-00805f9b34fb # generic access 服务
attr handle: 0x0008, end grp handle: 0x0008 uuid: 00001801-0000-1000-8000-00805f9b34fb # generic attribute 服务
attr handle: 0x0009, end grp handle: 0xffff uuid: 6e400001-b5a3-f393-e0a9-e50e24dcca9e # 未知服务

# 查看设备服务的特性
# handle是特性的句柄，char properties是特性的权限，char value handle是特性的数值句柄，uuid是特性的类型标识
[F4:52:53:51:F5:39][LE]> characteristics
handle: 0x0002, char properties: 0x0a, char value handle: 0x0003, uuid: 00002a00-0000-1000-8000-00805f9b34fb # Device Name
handle: 0x0004, char properties: 0x02, char value handle: 0x0005, uuid: 00002a01-0000-1000-8000-00805f9b34fb # Appearance
handle: 0x0006, char properties: 0x02, char value handle: 0x0007, uuid: 00002a04-0000-1000-8000-00805f9b34fb # Peripheral Preferred Connection Parameters
handle: 0x000a, char properties: 0x10, char value handle: 0x000b, uuid: 6e400003-b5a3-f393-e0a9-e50e24dcca9e
handle: 0x000d, char properties: 0x0c, char value handle: 0x000e, uuid: 6e400002-b5a3-f393-e0a9-e50e24dcca9e
handle: 0x000f, char properties: 0x0c, char value handle: 0x0010, uuid: 6e400004-b5a3-f393-e0a9-e50e24dcca9e

# 通过特性的数值句柄(char value handle)发送数据S
[F4:52:53:51:F5:39][LE]> char-write-req 0x000e FFFFFFFFFF0B0108010102010301010103
Characteristic value was written successfully
FFFFFFFFFF0E080B0101010101010101010000000C

# 通过特性的数值句柄(char value handle)读取数值
[F4:52:53:51:F5:39][LE]> char-read-hnd 0x000b
Characteristic value/descriptor: f9 21 92 19 21 00 65 01 49 49 21 09 20 09 21 09 22 09 23 09

# 设置安全等级为高，可以让设备长时间 Ubuntu保持连接
[F4:52:53:51:F5:39][LE]> sec-level high

# 断开连接
[F4:52:53:51:F5:39][LE]> disconnect
```

![](https://upload-images.jianshu.io/upload_images/15877540-ddc354bf62174a3c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



### 3.与BLE设备非交互式通讯

```shell
$ gatttool --help-all
Usage:
  gatttool [OPTION?]

Help Options:
  -h, --help                                Show help options
  --help-all                                Show all help options
  --help-gatt                               Show all GATT commands
  --help-params                             Show all Primary Services/Characteristics arguments
  --help-char-read-write                    Show all Characteristics Value/Descriptor Read/Write arguments

GATT commands
  --primary                                 Primary Service Discovery
  --characteristics                         Characteristics Discovery
  --char-read                               Characteristics Value/Descriptor Read
  --char-write                              Characteristics Value Write Without Response (Write Command)
  --char-write-req                          Characteristics Value Write (Write Request)
  --char-desc                               Characteristics Descriptor Discovery
  --listen                                  Listen for notifications and indications

Primary Services/Characteristics arguments
  -s, --start=0x0001                        Starting handle(optional)
  -e, --end=0xffff                          Ending handle(optional)
  -u, --uuid=0x1801                         UUID16 or UUID128(optional)

Characteristics Value/Descriptor Read/Write arguments
  -a, --handle=0x0001                       Read/Write characteristic by handle(required)
  -n, --value=0x0001                        Write characteristic value (required for write operation)

Application Options:
  -i, --adapter=hciX                        Specify local adapter interface
  -b, --device=MAC                          Specify remote Bluetooth address
  -t, --addr-type=[public | random]         Set LE address type. Default: public
  -m, --mtu=MTU                             Specify the MTU size
  -p, --psm=PSM                             Specify the PSM for GATT/ATT over BR/EDR
  -l, --sec-level=[low | medium | high]     Set security level. Default: low
  -I, --interactive                         Use interactive mode


# 寻找BLE设备中可用的服务
$ sudo gatttool -t random -b F4:52:53:51:F5:39 --primary
attr handle = 0x0001, end grp handle = 0x0007 uuid: 00001800-0000-1000-8000-00805f9b34fb
attr handle = 0x0008, end grp handle = 0x0008 uuid: 00001801-0000-1000-8000-00805f9b34fb
attr handle = 0x0009, end grp handle = 0xffff uuid: 6e400001-b5a3-f393-e0a9-e50e24dcca9e

f2:ac:55:b3:c5:05

# 查看设备服务的特性
$ sudo gatttool -t random -b F4:52:53:51:F5:39 --characteristics

# 通过特性的数值句柄(char value handle)读取数值
$ sudo gatttool -t random -b F4:52:53:51:F5:39 --char-read -a 0x000b

#  通过特性的数值句柄(char value handle)发送数据
$ sudo gatttool -t random -b F4:52:53:51:F5:39 --char-write-req -a 0x000e -n FFFFFFFFFF0B0108010102010301010103
$ sudo gatttool -t random -b f2:ac:55:b3:c5:05 --char-write-req -a 0x000d -n FFFFFFFFFF0B0108010102010301010103
```



### 4.BLE的UUID

低功耗蓝牙使用的UUID被分为5组：

- 0x1800 ~ 0x26FF：服务类型；
- 0x2700 ~ 0x27FF：计量单位；
- 0x2800 ~ 0x28FF：属性类型；
- 0x2900 ~ 0x29FF：特性描述；
- 0x2A00 ~ 0x7FFF：特性类型；

下面是SIG官网对各组UUID定义的链接地址：

- 服务类型：[https://www.bluetooth.com/specifications/gatt/services](https://links.jianshu.com/go?to=https%3A%2F%2Fwww.bluetooth.com%2Fspecifications%2Fgatt%2Fservices)
- 属性类型：[https://www.bluetooth.com/specifications/gatt/declarations](https://links.jianshu.com/go?to=https%3A%2F%2Fwww.bluetooth.com%2Fspecifications%2Fgatt%2Fdeclarations)
- 特性描述：[https://www.bluetooth.com/specifications/gatt/descriptors](https://links.jianshu.com/go?to=https%3A%2F%2Fwww.bluetooth.com%2Fspecifications%2Fgatt%2Fdescriptors)
- 特性类型：[https://www.bluetooth.com/specifications/gatt/characteristics](https://links.jianshu.com/go?to=https%3A%2F%2Fwww.bluetooth.com%2Fspecifications%2Fgatt%2Fcharacteristics)



```shell
# for testing
F2:AC:55:B3:C5:05
sudo gatttool -t random -b f2:ac:55:b3:c5:05 --primary
sudo gatttool -t random -b f2:ac:55:b3:c5:05 --characteristics
sudo gatttool -t random -b f2:ac:55:b3:c5:05 --char-write-req -a 0x000d -n FFFFFFFFFF0B0108010102010301010103
sudo gatttool -t random -b f2:ac:55:b3:c5:05 --char-write-req -a 0x000d -nF FFFFFFFFF0E080B0101010101010101010000000C
sudo gatttool -t random -b f2:ac:55:b3:c5:05 --char-read -a 0x000f
```

