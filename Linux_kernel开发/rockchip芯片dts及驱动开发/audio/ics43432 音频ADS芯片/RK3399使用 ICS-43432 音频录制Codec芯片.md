[TOC]



### 一、ICS-43432 简介

[官网 ICS-43432](https://invensense.tdk.com/products/digital/ics-43432/)

#### 1.基本特征

- 24-bit I2S interface
- Wide Frequency Response from 50 Hz to 20 kHz
- 用于录制的codec
  - 注意：一个codec一般只支持录制或者回放，例如回放就要用PCM5102 codec芯片

#### 2.引脚说明

![](https://upload-images.jianshu.io/upload_images/15877540-b0cd444b0d0cd1ed.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

I2S总线主要有3个信号：串行时钟BCLK、帧时钟LRCK、串行数据SDATA；有时为了使系统间能够更好地同步，还需要另外传输一个信号MCLK，称为主时钟，也叫系统时钟（Sys Clock）。

- 串行时钟BCLK：也叫SCLK，即对应数字音频的每一位数据，SCLK都有1个脉冲；SCLK的频率=2×采样频率×采样位数，2倍是因为I2S有左右两个通道。

- 帧时钟LRCK：用于切换左右声道的数据。LRCK为“1”表示正在传输的是左声道的数据，为“0”则表示正在传输的是右声道的数据；LRCK的频率等于采样频率。

- 串行数据SDATA：就是用二进制补码表示的音频数据。

对应SSI接口

- FS：WS/LRCLK
- CLK：SCK
- DR：SD

#### 3.时序图

![](https://upload-images.jianshu.io/upload_images/15877540-39cf6c0c8de9df0e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



![](https://upload-images.jianshu.io/upload_images/15877540-49da6a98123e929b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

 I2S format: left-justified, right-justified, and PCM modes.



逻辑分析仪实测时序图

（LF：默认拉低，所以使用左声道录音，右声道没有数据）

- 数据时钟频率是帧频率Fs的64倍（硬件配置决定）。

![](https://upload-images.jianshu.io/upload_images/15877540-b143de6fa73c710a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- Data Word Length：24 bits/channel
  - 一个I2S数据帧可以携带1-2个通道的数据， 一个通道的data word长度一般为16, 24, or 32 bits.
- Data Word Format：I2S, MSB-first.



### 二、RK3399 I2S配置

#### 1.RK3399 I2S资源

- I2S0接口有1路SDI，4路SDO，可以支持2个输入通道和8路输出声道。

![](https://upload-images.jianshu.io/upload_images/15877540-280903a16273f38f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- I2S1接口有1路SDI，1路SDO，可以支持2个输入通道和2路输出声道。

![](https://upload-images.jianshu.io/upload_images/15877540-f5c60ca6c22737d7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



#### 2.RK3399 I2S DTS配置

- I2S0

  ```shell
  &i2s0 {
  	rockchip,i2s-broken-burst-len;
  	rockchip,capture-channels = <8>;
  	rockchip,playback-channels = <8>;
  	#sound-dai-cells = <0>;
  	status = "okay";
  };
  
  / {
  	i2s0: i2s@ff880000 {
  		compatible = "rockchip,rk3399-i2s", "rockchip,rk3066-i2s";
  		reg = <0x0 0xff880000 0x0 0x1000>;
  		rockchip,grf = <&grf>;
  		interrupts = <GIC_SPI 39 IRQ_TYPE_LEVEL_HIGH 0>;
  		dmas = <&dmac_bus 0>, <&dmac_bus 1>;
  		dma-names = "tx", "rx";
  		clock-names = "i2s_clk", "i2s_hclk";
  		clocks = <&cru SCLK_I2S0_8CH>, <&cru HCLK_I2S0_8CH>;
  		resets = <&cru SRST_I2S0_8CH>, <&cru SRST_H_I2S0_8CH>;
  		reset-names = "reset-m", "reset-h";
  		pinctrl-names = "default";
  		pinctrl-0 = <&i2s0_8ch_bus>;
  		power-domains = <&power RK3399_PD_SDIOAUDIO>;
  		status = "disabled";
  	};
  };
  
  &pinctrl {
  	i2s0 {
  			i2s0_8ch_bus: i2s0-8ch-bus {
  				rockchip,pins =
  					<3 24 RK_FUNC_1 &pcfg_pull_none>,
  					<3 25 RK_FUNC_1 &pcfg_pull_none>,
  					<3 26 RK_FUNC_1 &pcfg_pull_none>,
  					<3 27 RK_FUNC_1 &pcfg_pull_none>,
  					<3 28 RK_FUNC_1 &pcfg_pull_none>,
  					<3 29 RK_FUNC_1 &pcfg_pull_none>,
  					<3 30 RK_FUNC_1 &pcfg_pull_none>,
  					<3 31 RK_FUNC_1 &pcfg_pull_none>;
  			};
  
  			i2s_8ch_mclk: i2s-8ch-mclk {
  				rockchip,pins = <4 0 RK_FUNC_1 &pcfg_pull_none>;
  			};
  		};
  };
  ```

- I2S1

  ```shell
  &i2s1 {
  	rockchip,i2s-broken-burst-len;
  	rockchip,playback-channels = <2>;
  	rockchip,capture-channels = <2>;
  	assigned-clocks = <&cru SCLK_I2S1_DIV>, <&cru SCLK_I2S_8CH>;
  	assigned-clock-parents = <&cru PLL_GPLL>, <&cru SCLK_I2S1_8CH>;
  	#sound-dai-cells = <0>;
  	status = "okay";
  };
  
  / {
  	i2s1: i2s@ff890000 {
  		compatible = "rockchip,rk3399-i2s", "rockchip,rk3066-i2s";
  		reg = <0x0 0xff890000 0x0 0x1000>;
  		interrupts = <GIC_SPI 40 IRQ_TYPE_LEVEL_HIGH 0>;
  		dmas = <&dmac_bus 2>, <&dmac_bus 3>;
  		dma-names = "tx", "rx";
  		clock-names = "i2s_clk", "i2s_hclk";
  		clocks = <&cru SCLK_I2S1_8CH>, <&cru HCLK_I2S1_8CH>;
  		resets = <&cru SRST_I2S1_8CH>, <&cru SRST_H_I2S1_8CH>;
  		reset-names = "reset-m", "reset-h";
  		pinctrl-names = "default";
  		pinctrl-0 = <&i2s1_2ch_bus>;
  		power-domains = <&power RK3399_PD_SDIOAUDIO>;
  		status = "disabled";
  	};
  };
  
  &pinctrl {
  	i2s1 {
  			i2s1_2ch_bus: i2s1-2ch-bus {
  				rockchip,pins =
  					<4 3 RK_FUNC_1 &pcfg_pull_none>,
  					<4 4 RK_FUNC_1 &pcfg_pull_none>,
  					<4 5 RK_FUNC_1 &pcfg_pull_none>,
  					<4 6 RK_FUNC_1 &pcfg_pull_none>,
  					<4 7 RK_FUNC_1 &pcfg_pull_none>;
  			};
  		};
  };
  ```

  

### 三、I2S数据格式

#### 1.I2S格式

![](https://winddoing.github.io/images/audio/I2S.png)

- LRCLK=0：左声道；LRCLK=1：右声道；

#### 2.LJ (Left Justified)

![](https://winddoing.github.io/images/audio/I2S-LJ.png)

- LRCLK=0：右声道；LRCLK=1：左声道；

#### 3.RJ (Left Justified)

![](https://winddoing.github.io/images/audio/I2S-RJ.png)

#### 4.I2S–八声道

![](https://winddoing.github.io/images/2019/02/i2s_channel_8.png)

- 2个输入通道
- 8个输出通道



### 四、设备树配置声卡驱动

- 使用Simple-audio-card 作为 machine driver，是一个简化音频框架，在alsa上面的一个封装。

- 使用dummy-codec虚拟声卡驱动，虚拟声卡，就是像这种soc外部没有外接codec的情况下，为了匹配声卡驱动框架，虚拟的一个设备，类似于占位符之类的东西的作用。
  
  - 使用dummy-codec也支持多声道，例如I2S0支持8个输出声道，2个输入声道，则可以在i2s0_sdo0---3接上4个回放型codec，在i2s0_sdi0接上1个录制型codec。linux系统使用aplay播放就可以选择8个通道，使用arecord录制可以选择2个通道。
  
  - 对于没有MCLK接口的Codec(如ICS-43432)，可以不用配置MCLK；对于有MCLK接口的（如PCM1804），则需要配置

```shell
/ {
	dummy_codec: dummy-codec {
		compatible = "rockchip,dummy-codec";
		#sound-dai-cells = <0>;
		clocks = <&cru SCLK_I2S_8CH_OUT>;
		clock-names = "mclk";
		pinctrl-names = "default";
		pinctrl-0 = <&i2s_8ch_mclk>;	//指定MCLK引脚
		// capture-volume = <0>;
		status = "okay";
	};

	dummy-sound {
		status = "okay";
		compatible = "simple-audio-card";
		simple-audio-card,format = "i2s";
		simple-audio-card,name = "rk,dummy-codec";
		simple-audio-card,mclk-fs = <256>;	// 指定MCLK频率为帧频率Fs的256倍
		simple-audio-card,cpu {
			sound-dai = <&i2s1>;
		};
		simple-audio-card,codec {
			sound-dai = <&dummy_codec>;
			#sound-dai-cells = <0>;
		};
	};
};
```



### 五、数字音频的质量

#### 1.香农采样定律

- 采样频率只要大于2*Fs，采集的数据即可无失真的还原原始信号，常见的CD，采样率为44.1KHz；这样当采样频率达到48KHz时即可无失真采样还原所有的声音信号。

#### 2.数字音频的质量影响因素

数字音频的质量取决于采样频率和量化位数这两个参数，为了保真，在时间变化方向上取样点尽量密，取样率要高；在幅度取值上尽量细，量化比特率要高，直接的结果就是存储容量及传输信道容量要求的压力大；



**音频信号的传输率= 取样频率 × 样本的量化比特数 × 通道数。**

![](https://upload-images.jianshu.io/upload_images/4859654-5fba7f4776315224.png?imageMogr2/auto-orient/strip|imageView2/2/w/773/format/webp)

```shell
# 对录制声卡进行音频录制，采样率为8KHz，量化比特数为16bits，信号通道数为2
$ arecord -D hw:2,0 -c 2 -f S16_LE -d 5 -v test.wav
Recording WAVE 'test.wav' : Signed 16 bit Little Endian, Rate 8000 Hz, Stereo
Hardware PCM card 2 'rk,dummy-codec' device 0 subdevice 0
Its setup is:
  stream       : CAPTURE
  access       : RW_INTERLEAVED
  format       : S16_LE
  subformat    : STD
  channels     : 2
  rate         : 8000
  exact rate   : 8000 (8000/1)
  msbits       : 16
  buffer_size  : 4000
  period_size  : 1000
  period_time  : 125000
  tstamp_mode  : NONE
  tstamp_type  : MONOTONIC
  period_step  : 1
  avail_min    : 1000
  period_event : 0
  start_threshold  : 1
  stop_threshold   : 4000
  silence_threshold: 0
  silence_size : 0
  boundary     : 9007199254740992000
  appl_ptr     : 0
  hw_ptr       : 0
```



