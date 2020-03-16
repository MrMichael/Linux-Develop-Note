[TOC]

### 一、NPU开发简介

#### 1.NPU特性

- 支持 8bit/16bit 运算，运算性能高达 3.0TOPS。
- 相较于 GPU 作为 AI 运算单元的大型芯片方案，功耗不到 GPU 所需要的 1%。
- 可直接加载 Caffe / Mxnet / TensorFlow 模型。
- 提供 AI 开发工具：支持模型快速转换、支持开发板端侧转换 API、支持 TensorFlow / TF Lite / Caffe / ONNX / Darknet 等模型 。
- 提供 AI 应用开发接口：支持 Android NN API、提供 RKNN 跨平台 API、Linux 支持 TensorFlow 开发。

#### 2.开发流程

NPU开发完整的流程如下图所示：

![_images/rknn_development_flow.png](http://wiki.t-firefly.com/zh_CN/3399pro_npu/_images/rknn_development_flow.png)

- 模型训练

  用户根据需求和实际情况选择合适的框架（如Caffe、TensorFlow等）进行训练得到符合需求的模型。也可直接使用已经训练好的模型。

- 模型转换

  通过RKNN Toolkit把模型训练中得到的模型转换为NPU可用的模型。

- 程序开发

  基于RKNN API或RKNN Tookit的Python API开发程序实现业务逻辑。



### 二、RKNN Toolkit (python)

RKNN-Toolkit 是为用户提供在 PC、 RK3399Pro、 RK1808、 TB-RK1808 AI 计算棒或 RK3399Pro
Linux 开发板上进行模型转换、推理和性能评估的开发套件。

用户通过提供的 python 接口可以便捷地完成以下功能：

1）模型转换：支持 Caffe、Tensorflow、TensorFlow Lite、ONNX、Darknet 模型，支持RKNN 模型导入导出，后续能够在硬件平台上加载使用。

2）模型推理：能够在 PC 上模拟运行模型并获取推理结果，也可以在指定硬件平台RK3399Pro Linux上运行模型并获取推理结果。

3）性能评估：能够在 PC 上模拟运行并获取模型总耗时及每一层的耗时信息，也可以通过联机调试的方式在指定硬件平台 RK3399Pro Linux上运行模型，并获取模型在硬件上运行时的总时间和每一层的耗时信息。



各操作系统(平台)的功能支持列表如下

![](https://upload-images.jianshu.io/upload_images/15877540-3c50b74c4bf03d66.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



#### 1.RKNN Toolkit安装

https://github.com/rockchip-linux/rknpu

http://repo.rock-chips.com/pypi/simple/

[下载链接](https://pan.baidu.com/s/1kr5fc80c3ZCkZJmFtpIEMQ)

- 安装环境依赖

![](https://upload-images.jianshu.io/upload_images/15877540-b70a34609391f3fc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```shell
sudo apt-get update
sudo apt-get install -y cmake python3 python3-pip python3-opencv \
    python3-h5py python3-lmdb libhdf5-serial-dev libgfortran5-dbg \
    protobuf-compiler libopenblas-dev gfortran libprotoc-dev
```

- 安装RKNN Toolkit及其依赖

```shell
pip3 uninstall numpy
pip3 install --user Cython \
    numpy==1.14.5 \
    protobuf==3.11.2 \
    onnx \
    scipy-1.2.0-cp36-cp36m-linux_aarch64.whl \
    tensorflow-1.10.1-cp36-cp36m-linux_aarch64.whl
    rknn-toolkit/packages/rknn_toolkit-1.3.0-cp36-cp36m-linux_aarch64.whl
```

- 通过 DOCKER 镜像安装

  在 docker 文件夹下提供了一个已打包所有开发环境的 Docker 镜像,用户只需要加载该镜像即可直接上手使用 RKNN-Toolkit，前提先装好docker环境。

  ```shell
  # 加载镜像
  docker load --input rknn-toolkit-1.3.0-docker.tar.gz
  # 查看镜像
  docker images
  # 运行镜像
  docker run -t -i --privileged -v /dev/bus/usb:/dev/bus/usb rknn-toolkit:1.3.0 /bin/bash
  # 运行 demo
  cd /example/tflite/mobilenet_v1
  python test.py
  ```



#### 2.API调用流程

- 模型转换

  ![](http://wiki.t-firefly.com/zh_CN/3399pro_npu/_images/rknn_toolkit_flowchart.png)

  模型转换使用示例如下,详细请参考RKNN Tookit中的example。

  ```python
  from rknn.api import RKNN  
   
  INPUT_SIZE = 64
   
  if __name__ == '__main__':
      # 创建RKNN执行对象
      rknn = RKNN()
      # 配置模型输入，用于NPU对数据输入的预处理
      # channel_mean_value='0 0 0 255'，那么模型推理时，将会对RGB数据做如下转换
      # (R - 0)/255, (G - 0)/255, (B - 0)/255。推理时，RKNN模型会自动做均值和归一化处理
      # reorder_channel=’0 1 2’用于指定是否调整图像通道顺序，设置成0 1 2即按输入的图像通道顺序不做调整
      # reorder_channel=’2 1 0’表示交换0和2通道，如果输入是RGB，将会被调整为BGR。如果是BGR将会被调整为RGB
      #图像通道顺序不做调整
      rknn.config(channel_mean_value='0 0 0 255', reorder_channel='0 1 2')
   
      # 加载TensorFlow模型
      # tf_pb='digital_gesture.pb'指定待转换的TensorFlow模型
      # inputs指定模型中的输入节点
      # outputs指定模型中输出节点
      # input_size_list指定模型输入的大小
      print('--> Loading model')
      rknn.load_tensorflow(tf_pb='digital_gesture.pb',
                           inputs=['input_x'],
                           outputs=['probability'],
                           input_size_list=[[INPUT_SIZE, INPUT_SIZE, 3]])
      print('done')
   
      # 创建解析pb模型
      # do_quantization=False指定不进行量化
      # 量化会减小模型的体积和提升运算速度，但是会有精度的丢失
      print('--> Building model')
      rknn.build(do_quantization=False)
      print('done')
   
      # 导出保存rknn模型文件
      rknn.export_rknn('./digital_gesture.rknn')
   
      # Release RKNN Context
      rknn.release()
  ```

- 模型推理

  ![](http://wiki.t-firefly.com/zh_CN/3399pro_npu/_images/rknn_toolkit_inference_flowchart.png)

  模型推理使用示例如下,详细请参考RKNN Tookit中的example。

  ```shell
  import numpy as np
  from PIL import Image
  from rknn.api import RKNN
  # 解析模型的输出，获得概率最大的手势和对应的概率
  def get_predict(probability):
      data = probability[0][0]
      data = data.tolist()
      max_prob = max(data)
   
      return data.index(max_prob), max_prob
  def load_model():
      # 创建RKNN对象
      rknn = RKNN()
      # 载入RKNN模型
      print('-->loading model')
      rknn.load_rknn('./digital_gesture.rknn')
      print('loading model done')
      # 初始化RKNN运行环境
      print('--> Init runtime environment')
      ret = rknn.init_runtime(target='rk3399pro')
      if ret != 0:
         print('Init runtime environment failed')
         exit(ret)
      print('done')
      return rknn
  def predict(rknn):
      im = Image.open("../picture/6_7.jpg")   # 加载图片
      im = im.resize((64, 64),Image.ANTIALIAS)  # 图像缩放到64x64
      mat = np.asarray(im.convert('RGB'))    # 转换成RGB格式
      outputs = rknn.inference(inputs=[mat])   # 运行推理，得到推理结果
      pred, prob = get_predict(outputs)     # 将推理结果转化为可视信息
      print(prob)
      print(pred)
   
  if __name__=="__main__":
      rknn = load_model()
      predict(rknn) 
   
      rknn.release()
  ```

   rknpu/rknn/python/example/mobilenet_v1/test.py 也是模型推理的过程



### 三、RKNN API (C++)

> rknpu/rknn/rknn_api

- Rockchip提供了一套RKNN API SDK，该SDK为基于 RK3399Pro Linux/Android 的神经网络NPU硬件的一套加速方案，可为采用RKNN API 开发的AI相关应用提供通用加速支持。
- 提供RKNN相关的C++ API函数，与RKNN python可以公用一套rknn模型，应用程序只需要包含该头文件和动态库，就可以编写相关的AI应用。

#### 1.安装头文件和动态库

```shell
# 导入rknn api 动态链接库
cp ~/rknpu/rknn/rknn_api/librknn_api/lib64/librknn_api.so /usr/lib/
cp ~/rknpu/rknn/rknn_api/librknn_api/include/rknn_api.h /usr/include/
```

#### 2.调用方法

```c
//a. 引用头文件：
#include <rockchip/rknn_api.h>

//b.在Makefile中添加如下语句设置链接库路径和头文件路径
CFLAGS += -Lrknn_api/lib64 -Irknn_api/include

//c. 在Makefile中添加如下语句链接库文件：
LDFLAGS += -lrknn_api
    
 //最终参考目录结构如下
  ...
├── Makefile
└── rknn_api
    ├── include
    │   └── rknn_api.h
    └── lib64
        └── librknn_api.so
 ...
```

