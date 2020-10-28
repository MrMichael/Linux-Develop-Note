



```shell
# 安装pci调试工具
sudo apt-get install pciutils

$ ls /sys/class/pci_bus/
0000:00  0000:01

# 查看pci设备信息
lspci -vv
00:00.0 PCI bridge: Fuzhou Rockchip Electronics Co., Ltd Device 0100 (prog-if 00 [Normal decode])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort+ <TAbort+ <MAbort+ >SERR+ <PERR+ INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 227
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	I/O behind bridge: 00000000-00000fff
	Memory behind bridge: fa000000-fa0fffff
	Prefetchable memory behind bridge: 00000000-000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport
lspci: Unable to load libkmod resources: error -12

01:00.0 Non-Volatile memory controller: Samsung Electronics Co Ltd NVMe SSD Controller SM981/PM981 (prog-if 02 [NVM Express])
	Subsystem: Samsung Electronics Co Ltd Device a801
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 226
	Region 0: Memory at fa000000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: <access denied>
	Kernel driver in use: nvme
	
# pcie启动信息
$ dmesg |grep pci
[    1.137224] phy phy-pcie-phy.5: Looking up phy-supply from device tree
[    1.137234] phy phy-pcie-phy.5: Looking up phy-supply property in node /pcie-phy failed
[    1.139207] rockchip-pcie f8000000.pcie: GPIO lookup for consumer ep
[    1.139216] rockchip-pcie f8000000.pcie: using device tree for GPIO lookup
[    1.139245] of_get_named_gpiod_flags: parsed 'ep-gpios' property of node '/pcie@f8000000[0]' - status (0)
[    1.139516] rockchip-pcie f8000000.pcie: Looking up vpcie3v3-supply from device tree
[    1.139622] rockchip-pcie f8000000.pcie: Looking up vpcie1v8-supply from device tree
[    1.139633] rockchip-pcie f8000000.pcie: Looking up vpcie1v8-supply property in node /pcie@f8000000 failed
[    1.139646] rockchip-pcie f8000000.pcie: no vpcie1v8 regulator found
[    1.146010] rockchip-pcie f8000000.pcie: Looking up vpcie0v9-supply from device tree
[    1.146020] rockchip-pcie f8000000.pcie: Looking up vpcie0v9-supply property in node /pcie@f8000000 failed
[    1.146031] rockchip-pcie f8000000.pcie: no vpcie0v9 regulator found
[    1.152391] rockchip-pcie f8000000.pcie: missing "memory-region" property
[    1.159198] PCI host bridge /pcie@f8000000 ranges:
[    1.216376] rockchip-pcie f8000000.pcie: invalid power supply
[    1.229022] rockchip-pcie f8000000.pcie: PCI host bridge to bus 0000:00
[    1.235656] pci_bus 0000:00: root bus resource [bus 00-1f]
[    1.241146] pci_bus 0000:00: root bus resource [mem 0xfa000000-0xfbdfffff]
[    1.248025] pci_bus 0000:00: root bus resource [io  0x0000-0xfffff] (bus address [0xfbe00000-0xfbefffff])
[    1.257620] pci 0000:00:00.0: [1d87:0100] type 01 class 0x060400
[    1.257724] pci 0000:00:00.0: supports D1
[    1.257732] pci 0000:00:00.0: PME# supported from D0 D1 D3hot
[    1.257982] pci 0000:00:00.0: bridge configuration invalid ([bus 00-00]), reconfiguring
[    1.266109] pci_bus 0000:01: busn_res: can not insert [bus 01-ff] under [bus 00-1f] (conflicts with (null) [bus 00-1f])
[    1.266149] pci 0000:01:00.0: [144d:a808] type 00 class 0x010802
[    1.266211] pci 0000:01:00.0: reg 0x10: [mem 0x00000000-0x00003fff 64bit]
[    1.268392] pci_bus 0000:01: busn_res: [bus 01-ff] end is updated to 01
[    1.268426] pci 0000:00:00.0: BAR 8: assigned [mem 0xfa000000-0xfa0fffff]
[    1.275231] pci 0000:01:00.0: BAR 0: assigned [mem 0xfa000000-0xfa003fff 64bit]
[    1.282557] pci 0000:00:00.0: PCI bridge to [bus 01]
[    1.287530] pci 0000:00:00.0:   bridge window [mem 0xfa000000-0xfa0fffff]
[    1.294384] pcieport 0000:00:00.0: enabling device (0000 -> 0002)
[    1.300714] pcieport 0000:00:00.0: Signaling PME through PCIe PME interrupt
[    1.307679] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
[    1.314209] pcie_pme 0000:00:00.0:pcie01: service driver pcie_pme loaded
[    1.314316] aer 0000:00:00.0:pcie02: service driver aer loaded
[    2.072897] ehci-pci: EHCI PCI platform driver
```

