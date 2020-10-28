### 使用方法

```shell
# 下载程序
cd $GOPATH/src
mkdir -p github.com/paypal && cd github.com/paypal
git clone https://github.com/paypal/gatt.git
cd gatt

#  程序提供server、 discoverer、explorer 三个测试样例
# Build the sample server.
go build examples/server.go
# Start the sample server.
sudo ./server

# Build the sample discoverer.
go build examples/discoverer.go
# Start the sample discoverer.
sudo ./discoverer

# Build the sample explorer.
go build examples/explorer.go
# Start the sample explorer.
sudo ./explorer EA:B6:0B:B3:17:D3
2020/06/16 17:47:06 dev: hci0 up
2020/06/16 17:47:06 dev: hci0 reset
2020/06/16 17:47:06 dev: hci0 down
2020/06/16 17:47:06 dev: hci0 opened
State: PoweredOn
Scanning...

Peripheral ID:EA:B6:0B:B3:17:D3, NAME:(CDEBYTE_BLE)
  Local Name        = CDEBYTE_BLE
  TX Power Level    = 0
  Manufacturer Data = []
  Service Data      = []

Connected
Service: 1800 (Generic Access)
  Characteristic  2a00 (Device Name)
    properties    read 
    value         434445425954455f424c45 | "CDEBYTE_BLE"
  Characteristic  2a01 (Appearance)
    properties    read 
    value         0200 | "\x02\x00"
  Characteristic  2a02 (Peripheral Privacy Flag)
    properties    read write 
    value         00 | "\x00"
  Characteristic  2a04 (Peripheral Preferred Connection Parameters)
    properties    read 
    value         6400c80000d00742 | "d\x00\xc8\x00\x00\xd0\aB"

Service: 1801 (Generic Attribute)
  Characteristic  2a05 (Service Changed)
    properties    indicate 
  Descriptor      2902 (Client Characteristic Configuration)
    value         0000 | "\x00\x00"

Service: 180a (Device Information)
2020/06/16 17:47:06 ignore l2cap signal:[ 0C 00 05 00 12 08 08 00 0C 00 14 00 00 00 58 02 ]
  Characteristic  2a29 (Manufacturer Name String)
    properties    read 
    value         43455641000000000000 | "CEVA\x00\x00\x00\x00\x00\x00"
  Characteristic  2a24 (Model Number String)
    properties    read 
    value         425420342e30 | "BT 4.0"
  Characteristic  2a25 (Serial Number String)
    properties    read 
    value         31327830377832303132 | "12x07x2012"
  Characteristic  2a27 (Hardware Revision String)
    properties    read 
    value         534d2d31 | "SM-1"
  Characteristic  2a28 (Software Revision String)
    properties    read 
    value         30312e31 | "01.1"
  Characteristic  2a23 (System ID)
    properties    read 
    value         debc9afeff563412 | "\u07bc\x9a\xfe\xffV4\x12"
  Characteristic  2a50 (PnP ID)
    properties    read 
    value         010e0012340167 | "\x01\x0e\x00\x124\x01g"

Service: fff0
  Characteristic  0000fff100001000800000805f9b34fb
    properties    read notify 
    value         61626364656667680000000000000000000000000000 | "abcdefgh\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
  Descriptor      2902 (Client Characteristic Configuration)
    value         0000 | "\x00\x00"
  Descriptor      2901 (Characteristic User Description)
    value         0000 | "\x00\x00"
  Characteristic  0000fff200001000800000805f9b34fb
    properties    read write 
    value         31323334353638000000000000000000000000000000 | "1234568\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
  Descriptor      2902 (Client Characteristic Configuration)
    value         0000 | "\x00\x00"
  Characteristic  0000fff300001000800000805f9b34fb
    properties    read write 
    value         00000000000000000000000000000000000000000000 | "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
  Descriptor      2902 (Client Characteristic Configuration)
    value         0000 | "\x00\x00"
```

