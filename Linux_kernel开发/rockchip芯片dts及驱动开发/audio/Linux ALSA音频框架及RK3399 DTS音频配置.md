[TOC]



# ALSA音频框架

Alsa是Advanced Linux Sound Architecture的缩写，即高级Linux声音架构，在Linux操作系统上提供了对音频和MIDI的支持。在Linux 2.6的内核版本后，Alsa目前已经成为了linux的主流音频体系结构。

除了 alsa-driver，ALSA 包含在用户空间的 alsa-lib 函数库，具有更加友好的编程接口，并且完全兼容于 OSS，开发者可以通过这些高级 API 使用驱动，不必直接与内核驱动 API 进行交互。



## 一、系统框架

![](https://upload-images.jianshu.io/upload_images/15877540-7c738b346bfbbfae.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



- User空间：主要由Alsa Libray API对应用程序提供统一的API接口，各个APP应用程序只要调用 alsa-lib 提供的 API接口来实现放音、录音、控制。现在提供了两套基本的库，tinyalsa是一个简化的alsa-lib库，现在Android的系统中主要使用它。

- ALSA CORE：alsa 核心层，向上提供逻辑设备（PCM/CTL/MIDI/TIMER/…）系统调用，向下驱动硬件设备（Machine/I2S/DMA/CODEC）

- ASOC Core：是 ALSA 的标准框架，是 ALSA-driver 的核心部分，提供了各种音频设备驱动的通用方法和数据结构，为 Audio driver提供 ALSA Driver API

- Hardware Driver：音频硬件设备驱动，由三大部分组成，分别是 Machine、Platform、Codec，提供的 ALSA Driver API 和相应音频设备的初始化及工作流程，实现具体的功能组件，这也是驱动开发人员需要具体实现的部分。



## 二、ASoC  硬件驱动结构

[ALSA driver--Asoc](https://www.cnblogs.com/fellow1988/p/6216123.html)

ASoC--ALSA System on Chip , 是建立在标准ALSA驱动层上, 为了更好地支持嵌入式处理器和移动设备中的音频Codec的一套软件体系.

嵌入式设备的音频系统可以被划分为板载硬件(Machine)、Soc(Platform)、Codec三大部分。

![](https://img2020.cnblogs.com/blog/1851249/202006/1851249-20200617090924475-1465027048.png)

![](https://images2015.cnblogs.com/blog/709240/201612/709240-20161223203916854-1074717321.png)

### 1. ASoC Platform Driver

指某款 SoC 平台的音频模块，如 exynos、omap、qcom 等等。

包括 dma 和 cpu_dai 两部分：

- dma：负责把 dma buffer 中的音频数据搬运到 I2S tx FIFO。音频 dma 驱动通过snd_soc_register_platform() 来注册。
- cpu dai：指 SoC 的 I2S、PCM 总线控制器，负责把音频数据从 I2S tx FIFO 搬运到 CODEC（这是回放的情形，录制则方向相反）。cpu_dai 通过 snd_soc_register_dai() 来注册。



### 2. ASoC Machine Driver

作为链结 Platform 和 Codec 的载体，通过配置 dai_link 把 cpu_dai、codec_dai、modem_dai 各个音频接口给链结成一条条音频链路，然后注册 snd_soc_card。

- snd_soc_dai_link：音频链路描述及板级操作函数，它指定链路用到的 codec、codec_dai、cpu_dai、platform，这四者就构成了一条音频数据链路用于多媒体声音的回放和录制。
- snd_soc_dai_driver：音频数据接口描述及操作函数，根据 codec 端和 soc 端，分为 codec_dai 和 cpu_dai。
  - linux 4.4 内核中支持两种方式创建dai_driver,  一种是通用的simple-audio-card 架构（简单通用的 machine driver）,  一种是传统的编写自定义的 machine driver 来创建。
- snd_soc_codec_driver：音频编解码芯片描述及操作函数，如控件/微件/音频路由的描述信息、时钟配置、IO 控制等
- snd_soc_platform_driver：音频 dma 设备描述及操作函数



#### 1）simple-audio-card

简单通用的 machine driver, 是一个为了简化音频框架，在alsa上面的一个封装。如果 simple-audio-card 框架足够满足需求, 建议优先使用 simple-audio-card 框架。

simple-audio-card的框架主要配置说明

```shell
status:声卡目前的状态，目前是未激活；
compatible:设备文件中的的名字，系统靠这个去匹配驱动代码中的simple-audio-card层的驱动程序；
simple-audio-card,name:声卡在系统中的名字；
simple-audio-card,cpu {
      sound-dai:soc端的dai 配置，就是rk3399的spdif或i2s接口的配置；
}
simple-audio-card,codec {
      sound-dai:codec端的dai配置，就是soc外界codec的接口的配置，这里是虚拟声卡；
}
```



### 3. ASoC Codec Driver

Codec 字面意思是编解码器，可以是用于回放或录制音频的。对于回放来说，userspace 送过来的音频数据是经过采样量化的数字信号，在 codec 经过 DAC 转换成模拟信号然后输出到外放或耳机，这样就可以听到声音了（对于录制则相反）。

Codec 芯片里面的功能部件很多，常见的有 AIF、DAC、ADC、Mixer、PGA、Line-in、Line-out，有些高端的 codec 芯片还有 EQ、DSP、SRC、DRC、AGC、Echo-Canceller、Noise-Suppression 等部件。

![](https://pic4.zhimg.com/80/v2-3bd41a072f6805bee42b017e2a9f66fb_720w.jpg)

Codec驱动主要提供以下特性：

- Codec DAI 和 PCM的配置信息；
- Codec的IO控制方式（I2C，SPI等）；
- Mixer和其他的音频控件；
- Codec的ALSA音频操作接口；
- DAPM描述信息；
- DAPM事件处理程序；
- DAC数字静音控制



#### 1）dummy_codec

ASoC Codec Driver之一，dummy_codec 是虚拟声卡 ，在soc外部没有外接codec的情况下，为了匹配声卡驱动框架，虚拟的一个设备，类似于占位符之类的东西的作用。





## 三、DTS实例

以rk3399为处理器，使用Simple-audio-card 作为machine driver，使用PCM5102芯片作为回放Codec，使用ICS-43432作为录制Codec，以此为基础配置设备树。

- PCM5102使用PCM5102 driver，绑定到I2S0。
- ICS-43432使用dummy_codec driver，绑定到I2S1。

```shell
/ {
	...
	pcm5102a:  pcm5102a {
		compatible = "ti,pcm5102a";
		#sound-dai-cells = <0>;
		status = "okay";
	};

	pcm5102-sound {
		status = "okay";
		compatible = "simple-audio-card";
		simple-audio-card,format = "i2s";
		simple-audio-card,name = "ti,pcm5102-codec";
		simple-audio-card,mclk-fs = <256>;
		// simple-audio-card,widgets =
		// 	"Microphone", "Mic Jack",
		// 	"Headphone", "Headphone Jack";
		// simple-audio-card,routing =
		// 	"Mic Jack", "MICBIAS1",
		// 	"IN1P", "Mic Jack",
		// 	"Headphone Jack", "HPOL",
		// 	"Headphone Jack", "HPOR";

		simple-audio-card,cpu {
			sound-dai = <&i2s0>;
		};
		simple-audio-card,codec {
			sound-dai = <&pcm5102a>;
			#sound-dai-cells = <0>;
		};
	};
	
	dummy_codec: dummy-codec {
        compatible = "rockchip,dummy-codec";
        #sound-dai-cells = <0>;
        capture-volume = <0>;
    };
    
    i2s-dmic-array {
		status = "okay";
		compatible = "simple-audio-card";
		simple-audio-card,format = "i2s";
		simple-audio-card,name = "rockchip,i2s-dmic-array";
		simple-audio-card,mclk-fs = <256>;
		simple-audio-card,cpu {
			sound-dai = <&i2s1>;
		};
		simple-audio-card,codec {
			sound-dai = <&dummy_codec>;
			#sound-dai-cells = <0>;
		};
	};
	
};
	
&i2s0 {
	rockchip,i2s-broken-burst-len;
	rockchip,capture-channels = <8>;
	rockchip,playback-channels = <8>;
	#sound-dai-cells = <0>;
	status = "okay";
};

&i2s1 {
	rockchip,i2s-broken-burst-len;
	rockchip,playback-channels = <2>;
	rockchip,capture-channels = <2>;
	assigned-clocks = <&cru SCLK_I2S1_DIV>, <&cru SCLK_I2S_8CH>;
	assigned-clock-parents = <&cru PLL_GPLL>, <&cru SCLK_I2S1_8CH>;
	#sound-dai-cells = <0>;
	status = "okay";
};
```

