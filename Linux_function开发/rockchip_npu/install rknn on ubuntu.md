

#### 安装rknpu依赖环境到ubuntu

```shell
cd ~
# 安装依赖环境
git clone https://github.com/rockchip-linux/rknpu.git
<project name="rknpu" path="external/rknpu" revision="1121c481b6fcff3f5b9982259192089c03c63725" upstream="master"/>

sudo apt-get update
sudo apt-get install -y cmake python3 python3-pip python3-opencv \
    python3-h5py python3-lmdb libhdf5-serial-dev libgfortran5-dbg \
    protobuf-compiler libopenblas-dev gfortran libprotoc-dev

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



#### 测试rknpu

```shell
# 测试rknn
cd ~/rknpu/rknn/python/example/mobilenet_v1
sudo python3 test.py
```

