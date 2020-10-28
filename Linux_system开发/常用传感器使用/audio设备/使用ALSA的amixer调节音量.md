#### 使用ALSA的amixer调节音量

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

