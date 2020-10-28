

### 坐标系统 WGS84 、 GCJ02 、BD09 互转

[在线坐标转换工具【百度09、国测局02（火星）、WGS84之间任意转换】](http://mapclub.cn/archives/2168)



#### 1.现在主要有以下几种坐标系 : 

- 美国标准（国际共识）**WGS-84**坐标系统（**地球坐标**）
- 中国标准（加密过后的坐标系统）**GCJ-02**坐标系统（**火星坐标**）。 



#### 2.各类地图软件所使用的坐标系

![](https://note.youdao.com/yws/public/resource/cd47a22e6b1c6c4ada2b0b1ab211b095/xmlnote/WEBRESOURCEfcaa07a13ddfb1838e984ba7a761dade/5676)

- GPS坐标为WGS84坐标系，度分格式；
- 谷歌地图使用WGS84坐标系，度分格式；
- 百度地图使用BD09坐标系，度格式；
- 高德地图采用GCJ02坐标系，度格式；



[谷歌地图坐标查询]([https://www.google.com/maps/place/23%C2%B010](https://www.google.com/maps/place/23°10))

![img](https://note.youdao.com/yws/public/resource/cd47a22e6b1c6c4ada2b0b1ab211b095/xmlnote/WEBRESOURCE43527b98eb42c411ea7fd322892eac6a/5663)

先纬度后经度，度分格式



[百度地图坐标查询](http://api.map.baidu.com/lbsapi/getpoint/index.html)

![](https://note.youdao.com/yws/public/resource/cd47a22e6b1c6c4ada2b0b1ab211b095/xmlnote/WEBRESOURCEb484cd25c6b10e368ac6a971847a258a/5657)

先经度后纬度，度格式



[高德地图坐标查询](https://lbs.amap.com/console/show/picker)

![](https://note.youdao.com/yws/public/resource/cd47a22e6b1c6c4ada2b0b1ab211b095/xmlnote/WEBRESOURCE1916d286273f8584feff1faf3a0bee47/5688)

先经度后纬度，度格式





#### 3.GPS原始数据帧

```shell
$GPGGA,060851.00,2231.46643,N,11355.13250,E,2,03,13.96,1491.3,M,-3.5,M,,0000*49

$GPGLL,2231.46643,N,11355.13250,E,060851.00,A,D*61

$GPGSA,A,2,15,13,194,,,,,,,,,,13.96,13.96,0.00*39

$GPGSV,2,1,06,15,18,206,34,13,43,177,30,194,16,143,24,19,25,148,19*44

$GPGSV,2,2,06,17,05,148,00,20,26,266,00*75

$GPRMC,060851.00,A,2231.46643,N,11355.13250,E,007.942,357.59,260917,,,D*68

$GPVTG,357.59,T,,M,007.942,N,014.709,K,D*36
```

测试原始坐标位置

​	$GPRMC,060851.00,A,2235.10896,N,11354.79188,E,007.942,357.59,260917,,,D*68



#### 4.度分格式与度格式转换方法

- 度分格式： 2235.10896,11354.79188。 （ 22度  35.10896分，  113度  54.79188分）

- 度格式 = 度+分/60，即 22.585149, 113.913198



#### 5.坐标纠偏

由于GPS数据采用WGS84坐标系，而百度地图是用BD-09坐标系，高德地图用火星坐标系（CGJ-02），

所以把度分格式转化为度格式后，应用平台还需要把数据由WGS84坐标系转化为响应的坐标系，否则定位会有偏差。

定位结果以[GPS定位纠偏地图](http://www.openluat.com/GPS-Offset.html)为准。