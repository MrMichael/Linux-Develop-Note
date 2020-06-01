[TOC]

[SDK](*https://github.com/rockchip-linux/)

### 一、rknpu

<project name="rknpu" path="external/rknpu" revision="1121c481b6fcff3f5b9982259192089c03c63725" upstream="master"/>

#### 1.目录结构

```shell
~/project/rk1808/rk1808_linux_release_v1.1.1_20191030/external/rknpu$ tree
.
├── drivers
│   ├── common
│   │   ├── etc
│   │   │   └── init.d
│   │   │       ├── S05NPU_init
│   │   │       └── S60NPU_init
│   │   └── usr
│   │       ├── bin
│   │       │   ├── restart_rknn.sh
│   │       │   ├── start_rknn.sh
│   │       │   └── start_usb.sh
│   │       └── lib
│   │           └── cl_viv_vx_ext.h
│   ├── linux-aarch64
│   │   └── usr
│   │       ├── bin
│   │       │   └── rknn_server
│   │       └── lib
│   │           ├── libCLC.so
│   │           ├── libGAL.so
│   │           ├── libneuralnetworks.so
│   │           ├── libNNGPUBinary.so
│   │           ├── libNNVXCBinary.so
│   │           ├── libOpenCL.so
│   │           ├── libOpenVX.so
│   │           ├── libOpenVXU.so
│   │           ├── libOvx12VXCBinary.so
│   │           ├── librknn_runtime.so
│   │           ├── libRKOpenCL.so
│   │           ├── libVSC.so
│   │           └── npu
│   │               └── rknn
│   │                   ├── memory_profile
│   │                   └── plugins
│   │                       ├── libann_plugin.so
│   │                       └── librknn_plugin.so
│   ├── linux-aarch64-mini
│   │   └── usr
│   │       ├── bin
│   │       │   └── rknn_server
│   │       └── lib
│   │           ├── libGAL.so
│   │           ├── libOpenVX.so
│   │           ├── libOpenVXU.so
│   │           ├── librknn_runtime.so
│   │           ├── libVSC_Lite.so
│   │           └── npu
│   │               └── rknn
│   │                   ├── memory_profile
│   │                   └── plugins
│   │                       ├── libann_plugin.so
│   │                       └── librknn_plugin.so
│   ├── linux-armhf
│   │   └── usr
│   │       ├── bin
│   │       │   └── rknn_server
│   │       └── lib
│   │           ├── libCLC.so
│   │           ├── libGAL.so
│   │           ├── libneuralnetworks.so
│   │           ├── libNNGPUBinary.so
│   │           ├── libNNVXCBinary.so
│   │           ├── libOpenVX.so
│   │           ├── libOpenVXU.so
│   │           ├── libOvx12VXCBinary.so
│   │           ├── librknn_runtime.so
│   │           ├── libVSC.so
│   │           └── npu
│   │               └── rknn
│   │                   └── plugins
│   │                       ├── libann_plugin.so
│   │                       └── librknn_plugin.so
│   ├── linux-armhf-mini
│   │   └── usr
│   │       ├── bin
│   │       │   └── rknn_server
│   │       └── lib
│   │           ├── libGAL.so
│   │           ├── libOpenVX.so
│   │           ├── libOpenVXU.so
│   │           ├── librknn_runtime.so
│   │           ├── libVSC_Lite.so
│   │           └── npu
│   │               └── rknn
│   │                   └── plugins
│   │                       ├── libann_plugin.so
│   │                       └── librknn_plugin.so
│   ├── npu_ko
│   │   ├── galcore_fedora.ko
│   │   ├── galcore.ko
│   │   ├── galcore_rk1806.ko
│   │   ├── galcore_rk3399pro-npu.ko
│   │   └── galcore_rk3399pro-npu-pcie.ko
│   └── README
└── rknn
    ├── include
    │   └── rknn_runtime.h
    ├── python
    │   ├── example
    │   │   └── mobilenet_v1								# mobilenet_v1
    │   │       ├── dog_224x224.jpg
    │   │       ├── mobilenet_v1.rknn
    │   │       └── test.py
    │   ├── rknn			# 旧版本，可忽略
    │   │   ├── api
    │   │   │   ├── __init__.py
    │   │   │   ├── rknn_base.cpython-36m-aarch64-linux-gnu.so
    │   │   │   ├── rknn_model.cpython-36m-aarch64-linux-gnu.so
    │   │   │   ├── rknn.py
    │   │   │   └── rknn_runtime.cpython-36m-aarch64-linux-gnu.so
    │   │   ├── __init__.py
    │   │   ├── README
    │   │   └── VERSION
    │   ├── rknn1808-1.2.0-cp36-cp36m-linux_aarch64.whl		# rknn
    │   └── rknn1808-1.2.0-cp37-cp37m-linux_aarch64.whl
    └── rknn_api
        ├── examples
        │   ├── libs
        │   │   └── opencv
        │   │       ├── include
        │   │       │   ├── opencv
        │   │       │   └── opencv2
        │   │       ├── lib
        │   │       │   ├── libopencv_core.so -> libopencv_core.so.3.4
        │   │       │   ├── libopencv_core.so.3.4 -> libopencv_core.so.3.4.1
        │   │       │   ├── libopencv_core.so.3.4.1
        │   │       │   ├── libopencv_highgui.so -> libopencv_highgui.so.3.4
        │   │       │   ├── libopencv_highgui.so.3.4 -> libopencv_highgui.so.3.4.1
        │   │       │   ├── libopencv_highgui.so.3.4.1
        │   │       │   ├── libopencv_imgcodecs.so -> libopencv_imgcodecs.so.3.4
        │   │       │   ├── libopencv_imgcodecs.so.3.4 -> libopencv_imgcodecs.so.3.4.1
        │   │       │   ├── libopencv_imgcodecs.so.3.4.1
        │   │       │   ├── libopencv_imgproc.so -> libopencv_imgproc.so.3.4
        │   │       │   ├── libopencv_imgproc.so.3.4 -> libopencv_imgproc.so.3.4.1
        │   │       │   └── libopencv_imgproc.so.3.4.1
        │   │       └── lib64
        │   │           ├── libopencv_core.so -> libopencv_core.so.3.4
        │   │           ├── libopencv_core.so.3.4
        │   │           ├── libopencv_highgui.so -> libopencv_highgui.so.3.4
        │   │           ├── libopencv_highgui.so.3.4
        │   │           ├── libopencv_imgcodecs.so -> libopencv_imgcodecs.so.3.4
        │   │           ├── libopencv_imgcodecs.so.3.4
        │   │           ├── libopencv_imgproc.so -> libopencv_imgproc.so.3.4
        │   │           └── libopencv_imgproc.so.3.4
        │   ├── rknn_mobilenet_demo
        │   │   ├── CMakeLists.txt
        │   │   ├── model
        │   │   │   ├── cat_224x224.jpg
        │   │   │   ├── dog_224x224.jpg
        │   │   │   └── mobilenet_v1.rknn
        │   │   ├── README.md
        │   │   └── src
        │   │       └── main.cc
        │   ├── rknn_ssd_demo
        │   │   ├── CMakeLists.txt
        │   │   ├── model
        │   │   │   ├── box_priors.txt
        │   │   │   ├── coco_labels_list.txt
        │   │   │   ├── road.bmp
        │   │   │   └── ssd_inception_v2.rknn
        │   │   ├── README.md
        │   │   └── src
        │   │       ├── main.cc
        │   │       ├── ssd.cc
        │   │       └── ssd.h
        │   └── rknn_yolo_demo
        │       ├── CMakeLists.txt
        │       ├── model
        │       │   ├── dog.jpg
        │       │   └── yolov3.rknn
        │       ├── README.md
        │       └── src
        │           ├── main.cc
        │           ├── yolov3_post_process.cc
        │           └── yolov3_post_process.h
        └── librknn_api
            ├── include
            │   └── rknn_api.h
            ├── lib
            │   └── librknn_api.so
            └── lib64
                └── librknn_api.so
```

#### 2.galcore.ko

```shell
~/project/rk1808/rk1808_linux_release_v1.1.1_20191030/external/rknpu$ modinfo ./drivers/npu_ko/galcore.ko 
filename:       /home/michael/project/rk1808/rk1808_linux_release_v1.1.1_20191030/external/rknpu/./drivers/npu_ko/galcore.ko
license:        Dual MIT/GPL
description:    Rockchip NPU Driver
alias:          of:N*T*Crockchip,npu*
depends:        
vermagic:       4.4.194 SMP preempt mod_unload aarch64
parm:           major:major device number for GC device (uint)
parm:           irqLine:IRQ number of GC core (int)
parm:           registerMemBase:Base of bus address of GC core AHB register (ulong)
parm:           registerMemSize:Size of bus address range of GC core AHB register (ulong)
parm:           irqLine2D:IRQ number of G2D core if irqLine is used for a G3D core (int)
parm:           registerMemBase2D:Base of bus address of G2D core if registerMemBase2D is used for a G3D core (ulong)
parm:           registerMemSize2D:Size of bus address range of G2D core if registerMemSize is used for a G3D core (ulong)
parm:           irqLineVG:IRQ number of VG core (int)
parm:           registerMemBaseVG:Base of bus address of VG core (ulong)
parm:           registerMemSizeVG:Size of bus address range of VG core (ulong)
parm:           contiguousSize:Size of memory reserved for GC (ulong)
parm:           contiguousBase:Base address of memory reserved for GC, if it is 0, GC driver will try to allocate a buffer whose size defined by contiguousSize (ullong)
parm:           externalSize:Size of external memory, if it is 0, means there is no external pool (ulong)
parm:           externalBase:Base address of external memory (ullong)
parm:           fastClear:Disable fast clear if set it to 0, enabled by default (int)
parm:           compression:Disable compression if set it to 0, enabled by default (int)
parm:           powerManagement:Disable auto power saving if set it to 0, enabled by default (int)
parm:           gpuProfiler:Enable profiling support, disabled by default (int)
parm:           baseAddress:Only used for old MMU, set it to 0 if memory which can be accessed by GPU falls into 0 - 2G, otherwise set it to 0x80000000 (ulong)
parm:           physSize:Obsolete (ulong)
parm:           recovery:Recover GPU from stuck (1: Enable, 0: Disable) (uint)
parm:           stuckDump:Level of stuck dump content (1: Minimal, 2: Middle, 3: Maximal) (uint)
parm:           showArgs:Display parameters value when driver loaded (int)
parm:           mmu:Disable MMU if set it to 0, enabled by default [Obsolete] (int)
parm:           irqs:Array of IRQ numbers of multi-GPU (array of int)
parm:           registerBases:Array of bases of bus address of register of multi-GPU (array of uint)
parm:           registerSizes:Array of sizes of bus address range of register of multi-GPU (array of uint)
parm:           chipIDs:Array of chipIDs of multi-GPU (array of uint)
parm:           type:0 - Char Driver (Default), 1 - Misc Driver (uint)
parm:           userClusterMask:User defined cluster enable mask (int)
parm:           smallBatch:Enable/disable small batch (int)
parm:           sRAMBases:Array of base of bus address of SRAM,INTERNAL, EXTERNAL0, EXTERNAL1..., gcvINVALID_PHYSICAL_ADDRESS means no bus address (array of ullong)
parm:           sRAMSizes:Array of size of per-core SRAMs, 0 means no SRAM (array of uint)
parm:           extSRAMBases:Shared SRAM physical address bases. (array of ullong)
parm:           extSRAMSizes:Shared SRAM sizes. (array of uint)
parm:           sRAMRequested:Default 1 means AXI-SRAM is already reserved for GPU, 0 means GPU driver need request the memory region. (uint)
parm:           sRAMLoopMode:Default 0 means SRAM pool must be specified when allocating SRAM memory, 1 means SRAM memory will be looped as default pool. (uint)
parm:           mmuPageTablePool:Default 1 means alloc mmu page table in virsual memory, 0 means auto select memory pool. (uint)
```

#### 3.安装rknpu依赖环境到ubuntu

```shell
cd ~
# 安装依赖环境
git clone https://github.com/rockchip-linux/rknpu.git
<project name="rknpu" path="external/rknpu" revision="1121c481b6fcff3f5b9982259192089c03c63725" upstream="master"/>

# 导入NPU内核模块文件galcore.ko
#sudo cp ~/rknpu/drivers/npu_ko/* /lib/modules/
sudo cp galcore.ko /lib/modules/

# 导入rknpu 动态链接库
cp -r ~/rknpu/drivers/linux-aarch64/usr/lib/* /usr/lib/

# 导入rknn api 动态链接库及头文件
cp ~/rknpu/rknn/rknn_api/librknn_api/lib64/librknn_api.so /usr/lib/
sudo cp ~/rknpu/rknn/rknn_api/librknn_api/include/rknn_api.h /usr/include/

# 安装python3 rknn软件包
sudo pip3 install  /home/admin/rknpu/rknn/python/rknn1808-1.2.0-cp36-cp36m-linux_aarch64.whl
#sudo cp ~/rknpu/rknn/rknn_api/librknn_api/lib64/librknn_api.so  /usr/local/lib/python3.6/dist-packages/rknn/

# 导入galcore.ko insmod脚本
sudo cp ~/rknpu/drivers/common/etc/init.d/S05NPU_init /etc/init.d/
sudo cp ~/rknpu/drivers/common/usr/lib/cl_viv_vx_ext.h/ /usr/lib/

# 修改/etc/rc.local
	/etc/init.d/S05NPU_init start
	
# 复制新的测试脚本
cp -r ~/rknpu/rknn/python/example/mobilenet_v1 ~/

# 移除rknpu
rm -rf ~/rknpu/
```

#### 4.测试rknpu

```shell
# 测试rknn
cd ~/rknpu/rknn/python/example/mobilenet_v1
sudo python3 test.py
```

$ cat rknpu/rknn/python/example/mobilenet_v1/test.py 

```python
import numpy as np
import cv2
from rknn.api import RKNN

def show_outputs(outputs):
    output = outputs[0][0]
    output_sorted = sorted(output, reverse=True)
    top5_str = 'mobilenet_v1\n-----TOP 5-----\n'
    for i in range(5):
        value = output_sorted[i]
        index = np.where(output == value)
        for j in range(len(index)):
            if (i + j) >= 5:
                break
            if value > 0:
                topi = '{}: {}\n'.format(index[j], value)
            else:
                topi = '-1: 0.0\n'
            top5_str += topi
    print(top5_str)

if __name__ == '__main__':

    # Create RKNN object
    rknn = RKNN()

    # Direct load rknn model
    print('--> Loading RKNN model')
    ret = rknn.load_rknn('./mobilenet_v1.rknn')
    if ret != 0:
       print('Load mobilenet_v1.rknn failed!')
       exit(ret)
    print('done')

    # Set inputs
    img = cv2.imread('./dog_224x224.jpg')
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    # Init Runtime
    rknn.init_runtime()

    # Inference
    print('--> Running model')
    outputs = rknn.inference(inputs=[img])
    show_outputs(outputs)
    print('done')

    rknn.release()
```



### 二、rknn-toolkit

<project name="rknn-toolkit" path="external/rknn-toolkit" revision="6169d559b15c710674723d9fd51e57d4792ef090" upstream="master"/>



#### 1.目录结构

```shell
~/project/rk1808/rk1808_linux_release_v1.1.1_20191030$ tree external/rknn-toolkit/
external/rknn-toolkit/
├── doc
│   ├── changelog-v1.3.0.txt
│   ├── Rockchip_Developer_Guide_RKNN_Toolkit_Custom_OP_CN.pdf
│   ├── Rockchip_Developer_Guide_RKNN_Toolkit_Custom_OP_EN.pdf
│   ├── Rockchip_Quick_Start_RKNN_Toolkit_V1.3.0_CN.pdf
│   ├── Rockchip_Quick_Start_RKNN_Toolkit_V1.3.0_EN.pdf
│   ├── Rockchip_Trouble_Shooting_RKNN_Toolkit_V1.3_CN.pdf
│   ├── Rockchip_Trouble_Shooting_RKNN_Toolkit_V1.3_EN.pdf
│   ├── Rockchip_User_Guide_RKNN_Toolkit_V1.3.0_CN.pdf
│   ├── Rockchip_User_Guide_RKNN_Toolkit_V1.3.0_EN.pdf
│   ├── Rockchip_User_Guide_RKNN_Toolkit_Visualization_CN.pdf
│   └── Rockchip_User_Guide_RKNN_Toolkit_Visualization_EN.pdf
├── examples
│   ├── caffe
│   │   ├── caffe_upsample
│   │   │   ├── cat.jpg
│   │   │   ├── dataset.txt
│   │   │   ├── deploy.prototxt
│   │   │   ├── solver_iter_45.caffemodel
│   │   │   └── test.py
│   │   ├── mobilenet_v2
│   │   │   ├── dataset.txt
│   │   │   ├── goldfish_224x224.jpg
│   │   │   ├── mobilenet_v2.caffemodel
│   │   │   ├── mobilenet_v2.prototxt
│   │   │   └── test.py
│   │   └── vgg-ssd
│   │       ├── dataset.txt
│   │       ├── deploy_rm_detection_output.prototxt
│   │       ├── mbox_priorbox_97.txt
│   │       ├── README
│   │       ├── road_300x300.jpg
│   │       └── test.py
│   ├── common_function_demos
│   │   ├── custom_op
│   │   │   ├── rknn_custom_op_math
│   │   │   │   ├── custom_op_math.pb
│   │   │   │   ├── exp
│   │   │   │   │   ├── Exp.rknnop
│   │   │   │   │   ├── makefile.linux.aarch64
│   │   │   │   │   ├── makefile.linux.x64
│   │   │   │   │   ├── op.yml
│   │   │   │   │   ├── rknn_kernel_exp.c
│   │   │   │   │   ├── rknn_kernel_exp.vx
│   │   │   │   │   └── rknn_op_exp.py
│   │   │   │   ├── exp.yml
│   │   │   │   ├── rknn_custom_op_math.py
│   │   │   │   ├── truncatediv
│   │   │   │   │   ├── makefile.linux.aarch64
│   │   │   │   │   ├── makefile.linux.x64
│   │   │   │   │   ├── op.yml
│   │   │   │   │   ├── rknn_kernel_truncatediv.c
│   │   │   │   │   ├── rknn_kernel_truncatediv.vx
│   │   │   │   │   ├── rknn_op_truncatediv.py
│   │   │   │   │   └── TruncateDiv.rknnop
│   │   │   │   └── truncatediv.yml
│   │   │   └── rknn_custom_op_resize
│   │   │       ├── dataset.txt
│   │   │       ├── dog_32x32.jpg
│   │   │       ├── out.jpg
│   │   │       ├── resize_area
│   │   │       │   ├── makefile.linux.aarch64
│   │   │       │   ├── makefile.linux.x64
│   │   │       │   ├── op.yml
│   │   │       │   ├── ResizeArea.rknnop
│   │   │       │   ├── rknn_kernel_resizearea.c
│   │   │       │   ├── rknn_kernel_resizearea.vx
│   │   │       │   └── rknn_op_resizearea.py
│   │   │       ├── resize_area.rknn
│   │   │       ├── resize_area_test.pb
│   │   │       ├── resize_area.yml
│   │   │       └── rknn_custom_op_resize_area.py
│   │   ├── export_rknn_precompile_model
│   │   │   ├── export_rknn_precompile_model.py
│   │   │   └── README.md
│   │   ├── hybrid_quantization
│   │   │   ├── box_priors.txt
│   │   │   ├── dataset.txt
│   │   │   ├── dog_bike_car_300x300.jpg
│   │   │   ├── quantization_profile.diff
│   │   │   ├── README.md
│   │   │   ├── ssd_mobilenet_v2.pb
│   │   │   ├── step1.py
│   │   │   ├── step2.py
│   │   │   ├── step3.py
│   │   │   └── val2017
│   │   │       ├── 000000000139.jpg
│   │   └── load_quantized_model
│   │       ├── goldfish_299x299.jpg
│   │       ├── README.md
│   │       └── test.py
│   ├── darknet
│   │   └── yolov3
│   │       ├── dataset.txt
│   │       ├── dog_bike_car_416x416.jpg
│   │       ├── test.py
│   │       └── yolov3.cfg
│   ├── mxnet
│   │   ├── fcn_resnet101
│   │   │   ├── dataset.txt
│   │   │   ├── test_image.jpeg
│   │   │   └── test.py
│   │   └── resnext50
│   │       ├── dataset.txt
│   │       ├── space_shuttle_224.jpg
│   │       └── test.py
│   ├── onnx
│   │   └── resnet50v2
│   │       ├── dataset.txt
│   │       ├── dog_224x224.jpg
│   │       ├── README
│   │       └── test.py
│   ├── pytorch
│   │   └── resnet18
│   │       ├── dataset.txt
│   │       ├── space_shuttle_224.jpg
│   │       └── test.py
│   ├── rknn_convert
│   │   ├── models
│   │   │   ├── caffe
│   │   │   │   └── mobilenet_v2
│   │   │   │       ├── model_config.yml
│   │   │   │       └── README
│   │   │   ├── tensorflow
│   │   │   │   └── mobilenet-ssd
│   │   │   │       ├── model_config.yml
│   │   │   │       └── README
│   │   │   └── tflite
│   │   │       └── mobilenet_v1
│   │   │           ├── model_config.yml
│   │   │           └── README
│   │   ├── README.md
│   │   └── rknn_convert.py
│   ├── tensorflow
│   │   └── ssd_mobilenet_v1
│   │       ├── box_priors.txt
│   │       ├── coco_labels_list.txt
│   │       ├── dataset.txt
│   │       ├── road.bmp
│   │       ├── ssd_mobilenet_v1_coco_2017_11_17.pb
│   │       └── ssd.py
│   └── tflite
│       └── mobilenet_v1
│           ├── dataset.txt
│           ├── dog_224x224.jpg
│           ├── mobilenet_v1.tflite
│           └── test.py
├── packages
│   ├── packages.md5sum
│   ├── README.md
│   ├── required-packages-for-arm64-debian9-python35
│   │   ├── opencv_python_headless-4.0.1.23-cp35-cp35m-linux_aarch64.whl
│   │   ├── required-packages-for-arm64-debian9-python35.md5sum
│   │   └── tensorflow-1.11.0-cp35-none-linux_aarch64.whl
│   ├── required-packages-for-win-python36
│   │   ├── lmdb-0.95-cp36-cp36m-win_amd64.whl
│   │   └── lmdb-0.95-cp36-cp36m-win_amd64.whl.md5sum
│   ├── requirements-cpu.txt
│   └── requirements-gpu.txt
├── platform-tools
│   ├── drivers_installer
│   │   └── windows-x86_64
│   │       ├── zadig-2.4.exe
│   │       └── zadig-2.4.exe.md5sum
│   ├── ntp
│   │   ├── linux-aarch64
│   │   │   ├── npu_transfer_proxy
│   │   │   └── npu_transfer_proxy.md5sum
│   │   └── mac-osx-x86_64
│   │       ├── npu_transfer_proxy
│   │       └── npu_transfer_proxy.md5sum
│   └── update_rk_usb_rule
│       └── linux
│           ├── README-EN.txt
│           ├── README.txt
│           └── update_rk1808_usb_rule.sh
└── README.md
```





