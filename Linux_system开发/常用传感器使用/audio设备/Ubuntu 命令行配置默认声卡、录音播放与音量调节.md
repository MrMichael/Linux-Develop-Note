[TOC]

### 一、alsa设置默认声卡

[alsa设置默认声卡](https://blog.csdn.net/hunanchenxingyu/article/details/48399585)

[理解和使用Alsa的配置文件](https://blog.csdn.net/colorant/article/details/2598815)

alsa的配置文件是alsa.conf位于/usr/share/alsa目录下，通常还有/usr/share/alsa/card和/usr/share/alsa/pcm两个子目录用来设置card相关的参数，别名以及一些PCM默认设置。



#### 1.安装alsa相关应用

```shell
sudo apt-get install alsa-base alsa-utils alsa-oss alsa-tools
```



#### 2.查看系统中的声卡

[免驱蓝牙适配器](https://item.taobao.com/item.htm?spm=a1z09.2.0.0.235e2e8dO2E7aX&id=589055588163&_u=42029oc528bcb8)

```shell
# 查看声卡
cat /proc/asound/cards
 0 [tegrahda       ]: tegra-hda - tegra-hda
                      tegra-hda at 0x70038000 irq 82
 1 [tegrasndt210ref]: tegra-snd-t210r - tegra-snd-t210ref-mobile-rt565x
                      tegra-snd-t210ref-mobile-rt565x
 2 [Adaptor        ]: USB-Audio - CSR Audio Adaptor
                      CSR Audio Adaptor at usb-70090000.xusb-2.3, full speed
                      
# 查看播放设备
$ sudo aplay -l                                                                                                                       
**** List of PLAYBACK Hardware Devices ****
card 0: rkhdmidpsound [rk-hdmi-dp-sound], device 0: HDMI-DP i2s-hifi-0 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: tipcm5102codec [ti,pcm5102-codec], device 0: ff880000.i2s-pcm5102a-hifi pcm5102a-hifi-0 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
                    
# 查看录音设备
$ sudo arecord -l
**** List of CAPTURE Hardware Devices ****
card 0: PCH [HDA Intel PCH], device 0: ALC3234 Analog [ALC3234 Analog]
  Subdevices: 0/1
  Subdevice #0: subdevice #0
```

- 每一个声卡有一个card number和一个device number

```shell
$ sudo aplay -l
**** List of PLAYBACK Hardware Devices ****
Home directory not accessible: Permission denied
card 0: tegrahda [tegra-hda], device 3: HDMI 0 [HDMI 0]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: tegrasndt210ref [tegra-snd-t210ref-mobile-rt565x], device 0: ADMAIF1 CIF ADMAIF1-0 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: tegrasndt210ref [tegra-snd-t210ref-mobile-rt565x], device 1: ADMAIF2 CIF ADMAIF2-1 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: tegrasndt210ref [tegra-snd-t210ref-mobile-rt565x], device 2: ADMAIF3 CIF ADMAIF3-2 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: tegrasndt210ref [tegra-snd-t210ref-mobile-rt565x], device 3: ADMAIF4 CIF ADMAIF4-3 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: tegrasndt210ref [tegra-snd-t210ref-mobile-rt565x], device 4: ADMAIF5 CIF ADMAIF5-4 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: tegrasndt210ref [tegra-snd-t210ref-mobile-rt565x], device 5: ADMAIF6 CIF ADMAIF6-5 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: tegrasndt210ref [tegra-snd-t210ref-mobile-rt565x], device 6: ADMAIF7 CIF ADMAIF7-6 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: tegrasndt210ref [tegra-snd-t210ref-mobile-rt565x], device 7: ADMAIF8 CIF ADMAIF8-7 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: tegrasndt210ref [tegra-snd-t210ref-mobile-rt565x], device 8: ADMAIF9 CIF ADMAIF9-8 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: tegrasndt210ref [tegra-snd-t210ref-mobile-rt565x], device 9: ADMAIF10 CIF ADMAIF10-9 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 2: Adaptor [CSR Audio Adaptor], device 0: USB Audio [USB Audio]
  Subdevices: 1/1
  Subdevice #0: subdevice #0

```

- alsa设置了一个defaults设备，音频播放软件默认使用defaults设备输出声音。defaults设备定义在alsa.conf中。defaults会默认匹配card number和device number比较小的声卡。如果要修改默认声卡，则修改/etc/asound.conf或~/.asoundrc文件。

```shell
...
defaults.ctl.card 0
defaults.pcm.card 0
defaults.pcm.device 0
defaults.pcm.subdevice -1
defaults.pcm.nonblock 1
defaults.pcm.compat 0
defaults.pcm.minperiodtime 5000         # in us
defaults.pcm.ipc_key 5678293
defaults.pcm.ipc_gid audio
defaults.pcm.ipc_perm 0660
defaults.pcm.dmix.max_periods 0
defaults.pcm.dmix.rate 48000
defaults.pcm.dmix.format "unchanged"
defaults.pcm.dmix.card defaults.pcm.card
defaults.pcm.dmix.device defaults.pcm.device
defaults.pcm.dsnoop.card defaults.pcm.card
defaults.pcm.dsnoop.device defaults.pcm.device
defaults.pcm.front.card defaults.pcm.card
defaults.pcm.front.device defaults.pcm.device
defaults.pcm.rear.card defaults.pcm.card
defaults.pcm.rear.device defaults.pcm.device
defaults.pcm.center_lfe.card defaults.pcm.card
defaults.pcm.center_lfe.device defaults.pcm.device
defaults.pcm.side.card defaults.pcm.card
defaults.pcm.side.device defaults.pcm.device
defaults.pcm.surround21.card defaults.pcm.card
defaults.pcm.surround21.device defaults.pcm.device
defaults.pcm.surround40.card defaults.pcm.card

...
```



#### 3.使用 ~/.asoundrc配置默认声卡

用户配置

https://alsa.opensrc.org/Asoundrc

在home目录添加 .asoundrc文件:

```shell
vi .asoundrc # 【测试可用】
defaults.ctl.card 2 
defaults.pcm.card 2
defaults.pcm.device 0
```



#### 4.使用/etc/asound.conf配置默认声卡

[alsa 配置文件asound.conf](https://blog.csdn.net/weixin_41965270/article/details/81272710)

全局配置

```shell
pcm.!default {
        type plug
        slave {
                pcm "hw:tegrasndt210ref,0"
                channels 2
                rate 48000
        }
        hint.description "Tegra APE Soundcard (tegrasndt210ref,0)"
}

ctl.!default {
        type hw
        card tegrasndt210ref
}

pcm.music {
        type plug
        slave {
                pcm "hw:tegrasndt210ref,0"
                channels 2
                rate 48000
        }
}

pcm.demixer {
        type plug
        slave {
                pcm "dmix:tegrasndt210ref"
                channels 2
                rate 48000
        }
}

pcm.aux {
        type hw
        card "Tegra"
        device 3
}

pcm.voice {
        type plug
        slave {
                pcm "hw:tegrasndt210ref,2"
                channels 1
                rate 8000
        }
}

pcm.aux_plug {
        type plug
        slave.pcm "aux"
}

pcm.music_and_voice {
        type asym

        playback.pcm {
                type plug

                slave.pcm {
                        type multi

                        slaves.a.pcm music
                        slaves.b.pcm voice
                        slaves.a.channels 2
                        slaves.b.channels 1

                        bindings.0.slave a
                        bindings.0.channel 0
                        bindings.1.slave a
                        bindings.1.channel 1
                        bindings.2.slave b
                        bindings.2.channel 0
                }
                route_policy duplicate
        }
        capture.pcm "voice"
}
```

在文件最后添加一下内容

```shell
$ sudo vim /etc/asound.conf   
defaults.pcm.card 2  
defaults.ctl.card 2  
```



#### 5.命令行指定录音和播放设备

```shell
# 选择默认设备录音
arecord -d 3 demo.wav
# 选择特定设备录音 【测试可用】
arecord -d 3 -D "plug:SLAVE='hw:2,0'" sample.wav  
	# 注意：-D 指定设备  参考aplay -l
	# -d 指定延时,单位秒
arecord -D hw:2,0 -c 2 -f S16_LE -d 5 -v test.wav

# 选择默认设备播放 【测试可用】 受系统音量调节
aplay demo.wav
# 选择特定设备播放 【测试可用】 不受系统音量调节
aplay -D "plug:SLAVE='hw:2,0'" sample.wav
```



#### 6.使用pacmd命令配置默认声卡

```shell
# 查看系统声卡
sudo pacmd list-sinks | grep name:
        name: <alsa_output.platform-70030000.hda.hdmi-stereo>
        name: <alsa_output.usb-0a12_CSR_Audio_Adaptor-00.analog-stereo>
        name: <alsa_output.platform-sound.analog-stereo>

# 设置默认输出声卡 【测试不可用】
sudo pacmd set-default-sink alsa_output.usb-0a12_CSR_Audio_Adaptor-00.analog-stereo

sudo pacmd list-sources | grep name:

# 设置默认输入麦克风
pacmd set-default-source "SOURCENAME"
```

- 需要有PulseAudio守护进程在后台运行



### 二、调节系统音量

#### 1.使用ALSA的amixer调节音量

1）调节常用命令

[ubuntu操音量调整命令amixer](https://blog.csdn.net/qushaobo/article/details/81324483)

```shell
$ sudo amixer -h
Usage: amixer <options> [command]

Available options:
  -h,--help       this help
  -c,--card N     select the card
  -D,--device N   select the device, default 'default'
  -d,--debug      debug mode
  -n,--nocheck    do not perform range checking
  -v,--version    print version of this program
  -q,--quiet      be quiet
  -i,--inactive   show also inactive controls
  -a,--abstract L select abstraction level (none or basic)
  -s,--stdin      Read and execute commands from stdin sequentially
  -R,--raw-volume Use the raw value (default)
  -M,--mapped-volume Use the mapped volume

Available commands:
  scontrols       show all mixer simple controls
  scontents	  show contents of all mixer simple controls (default command)
  sset sID P      set contents for one mixer simple control
  sget sID        get contents for one mixer simple control
  controls        show all controls for given card
  contents        show contents of all controls for given card
  cset cID P      set control contents for one control
  cget cID        get control contents for one control

# 解除静音
sudo amixer set 'Master' unmute

sudo amixer -c 0 sset 'Master',0 100%,80% unmute
	# -c 选择声卡， 不设置则为默认
	#  'Master',0：Simple mixer control
	# 100%,80% ： 左声道、右声道音量
```

2）使用softvol控制主音量

[Softvol](https://alsa.opensrc.org/Softvol)

[如何使用softvol控制主音量](https://alsa.opensrc.org/How_to_use_softvol_to_control_the_master_volume)

如果声卡无法控制硬件的音量(如PCM5102)，或者驱动程序不支持声卡的此功能，则可以定义一个新的虚拟pcm设备，该设备将控制软件方面的音量。

- 设置全局音频配置文件

  ```shell
  $ sudo vim /etc/asound.conf
      pcm.softdevice {
          type            softvol
          slave.pcm       "default"
          control.name    "Softmaster"
          control.card    1
      }
      # 设置默认声卡
      defaults.pcm.card 1
      defaults.ctl.card 1 
  ```

  这将创建一个名为softdevice的新PCM设备，其音量由名为`Softmaster`的新音量控件控制 。音量改变的音频流将被传送到 `default`设备。由于该插件没有任何变化，因此新设备的音量， *[采样格式](https://alsa.opensrc.org/Softvol?title=Sample_format&action=edit&redlink=1)*， *[采样率](https://alsa.opensrc.org/Softvol?title=Sample_rate&action=edit&redlink=1)* 和*通道数*与从设备的值相同。

- 首次使用新定义的设备

  只有使用一次新PCM设备后，才会出现Softmaster控件，同时也可以通过alsamixer 调节音量

  ```shell
  $ sudo speaker-test  -D softdevice
  
  $ amixer 
  Simple mixer control 'Softmaster',0
    Capabilities: volume
    Playback channels: Front Left - Front Right
    Capture channels: Front Left - Front Right
    Limits: 0 - 255
    Front Left: 156 [61%]
    Front Right: 156 [61%]
  ```

- 保存配置

  ```shell
  $ alsactl store -f /var/lib/alsa/asound.state  
  
  $ cat /var/lib/alsa/asound.state
  ...
  state.tipcm5102codec {
  	control.1 {
  		iface MIXER
  		name Softmaster
  		value.0 156
  		value.1 156
  		comment {
  			access 'read write user'
  			type INTEGER
  			count 2
  			range '0 - 255'
  			tlv '00000001000000080000000000000014'
  			dbmin 0
  			dbmax 5100
  			dbvalue.0 3120
  			dbvalue.1 3120
  		}
  	}
  }
  ...
  ```

- 修改音量与播放

  ```shell
  sudo amixer -c 1 sset 'Softmaster',0 80%,80% unmute
  
  # 播放音频
  sudo aplay -d 2 -D softdevice audio_test.wav
  ```



#### 2.使用pulseaudio的pactl调节音量

[Ubuntu Linux：从命令行和键盘快捷方式增加减少音量](http://www.yeslib.com/detail/3646)

使用是pulseaudio的自带命令pactl 

```shell
sudo apt-get install pulseaudio

# 查看音频设备的名称或索引号
pactl list short sinks
0       alsa_output.platform-70030000.hda.hdmi-stereo   module-alsa-card.c      s16le 2ch 44100Hz       SUSPENDED
1       alsa_output.usb-0a12_CSR_Audio_Adaptor-00.analog-stereo  module-alsa-card.c      s16le 2ch 48000Hz       RUNNING
2       alsa_output.platform-sound.analog-stereo        module-alsa-card.c      s16le 2ch 44100Hz       SUSPENDED

# 将音量提高10％ 【测试可用】
pactl -- set-sink-volume 1 +10%

# 将音量降低10％
pactl -- set-sink-volume 1 -10%

# 将音量设置为200％
pactl -- set-sink-volume 1 100%


# 查看音频输入输出设备
pactl list short sources
0       alsa_output.platform-70030000.hda.hdmi-stereo.monitor   module-alsa-card.c      s16le 2ch 44100Hz       SUSPENDED
1       alsa_output.usb-0a12_CSR_Audio_Adaptor-00.analog-stereo.monitor module-alsa-card.c      s16le 2ch 48000Hz       SUSPENDED
2       alsa_input.usb-0a12_CSR_Audio_Adaptor-00.analog-mono    module-alsa-card.c      s16le 1ch 48000Hz       SUSPENDED
3       alsa_output.platform-sound.analog-stereo.monitor        module-alsa-card.c      s16le 2ch 44100Hz       SUSPENDED
4       alsa_input.platform-sound.analog-stereo module-alsa-card.c      s16le 2ch 44100Hz       SUSPENDED

# 设置默认音频输出设备 【测试不可用】
pactl set-default-sink alsa_output.usb-0a12_CSR_Audio_Adaptor-00.analog-stereo.monitor

# 设置默认音频输入设备 【测试不可用】
pactl set-default-source  alsa_input.usb-0a12_CSR_Audio_Adaptor-00.analog-mono
```



### 三、问题调试

1.系统不播放音乐，连接过了10分钟，蓝牙自带断开

- 原因：蓝牙音箱一段时间没有声音会自动休眠。
- 解决办法：需要定期给蓝牙音箱播放一段空白语音，以保持蓝牙连接正常。



2.root用户无法调节系统音量

- pulseaudio来管理音频设备的，而pulseaudio不允许在root用户下运行，这样会导致安全问题。

  ```shell
  root@michael-desktop:/# pulseaudio 
  W: [pulseaudio] main.c: This program is not intended to be run as root (unless --system is specified).
  E: [pulseaudio] pid.c: Daemon already running.
  E: [pulseaudio] main.c: pa_pid_file_create() failed.
  ```

- [Ubuntu 11.04 root用户没有声音的问题](http://www.linuxdiyf.com/linux/6761.html)

- 解决方法：跨用户调用命令 【可用】

  ```shell
  # 录音
  su - nano -c "arecord -d 3 -D \"plug:SLAVE='hw:2,0'\" sample.wav"
  
  # 播放声音
  su - nano -c "aplay sample.wav"
  
  # 调节音量
  su - nano -c "pactl -- set-sink-volume 1 100%"
  ```

  