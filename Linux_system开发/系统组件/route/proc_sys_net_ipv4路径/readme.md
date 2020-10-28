[TOC]

### 修改Linux内核参数的方法

#### 1.直接在/proc/sys/目录下修改

```shell
$ tree /proc/sys/ -L 2
/proc/sys/
├── debug
│   └── exception-trace
├── dev
│   ├── scsi
│   └── tty
├── fs
│   ├── aio-max-nr
│   ├── aio-nr
│   ├── dentry-state
│   ├── epoll
│   ├── file-max
│   ├── file-nr
│   ├── inode-nr
│   ├── inode-state
│   ├── inotify
│   ├── lease-break-time
│   ├── leases-enable
│   ├── mount-max
│   ├── mqueue
│   ├── nr_open
│   ├── overflowgid
│   ├── overflowuid
│   ├── pipe-max-size
│   ├── pipe-user-pages-hard
│   ├── pipe-user-pages-soft
│   ├── protected_fifos
│   ├── protected_hardlinks
│   ├── protected_regular
│   ├── protected_symlinks
│   └── suid_dumpable
├── kernel
│   ├── auto_msgmni
│   ├── cad_pid
│   ├── cap_last_cap
│   ├── compat-log
│   ├── core_pattern
│   ├── core_pipe_limit
│   ├── core_uses_pid
│   ├── ctrl-alt-del
│   ├── dmesg_restrict
│   ├── domainname
│   ├── hardlockup_all_cpu_backtrace
│   ├── hardlockup_panic
│   ├── hostname
│   ├── hotplug
│   ├── hung_task_check_count
│   ├── hung_task_panic
│   ├── hung_task_timeout_secs
│   ├── hung_task_warnings
│   ├── keys
│   ├── kptr_restrict
│   ├── max_lock_depth
│   ├── modprobe
│   ├── modules_disabled
│   ├── msgmax
│   ├── msgmnb
│   ├── msgmni
│   ├── ngroups_max
│   ├── nmi_watchdog
│   ├── osrelease
│   ├── ostype
│   ├── overflowgid
│   ├── overflowuid
│   ├── panic
│   ├── panic_on_oops
│   ├── panic_on_warn
│   ├── perf_cpu_time_max_percent
│   ├── perf_event_max_sample_rate
│   ├── perf_event_mlock_kb
│   ├── perf_event_paranoid
│   ├── pid_max
│   ├── poweroff_cmd
│   ├── print-fatal-signals
│   ├── printk
│   ├── printk_delay
│   ├── printk_ratelimit
│   ├── printk_ratelimit_burst
│   ├── pty
│   ├── random
│   ├── randomize_va_space
│   ├── real-root-dev
│   ├── sched_child_runs_first
│   ├── sched_rr_timeslice_ms
│   ├── sched_rt_period_us
│   ├── sched_rt_runtime_us
│   ├── sem
│   ├── sg-big-buff
│   ├── shm_rmid_forced
│   ├── shmall
│   ├── shmmax
│   ├── shmmni
│   ├── soft_watchdog
│   ├── softlockup_all_cpu_backtrace
│   ├── softlockup_panic
│   ├── sysctl_writes_strict
│   ├── sysrq
│   ├── tainted
│   ├── threads-max
│   ├── timer_migration
│   ├── usermodehelper
│   ├── version
│   ├── watchdog
│   ├── watchdog_cpumask
│   └── watchdog_thresh
├── net
│   ├── core
│   ├── ipv4
│   ├── ipv6
│   ├── netfilter
│   ├── nf_conntrack_max
│   └── unix
└── vm
    ├── admin_reserve_kbytes
    ├── block_dump
    ├── dirty_background_bytes
    ├── dirty_background_ratio
    ├── dirty_bytes
    ├── dirty_expire_centisecs
    ├── dirty_ratio
    ├── dirty_writeback_centisecs
    ├── dirtytime_expire_seconds
    ├── drop_caches
    ├── extra_free_kbytes
    ├── laptop_mode
    ├── legacy_va_layout
    ├── lowmem_reserve_ratio
    ├── max_map_count
    ├── min_free_kbytes
    ├── mmap_min_addr
    ├── mmap_rnd_bits
    ├── mmap_rnd_compat_bits
    ├── nr_pdflush_threads
    ├── oom_dump_tasks
    ├── oom_kill_allocating_task
    ├── overcommit_kbytes
    ├── overcommit_memory
    ├── overcommit_ratio
    ├── page-cluster
    ├── panic_on_oom
    ├── percpu_pagelist_fraction
    ├── stat_interval
    ├── swappiness
    ├── user_reserve_kbytes
    └── vfs_cache_pressure
```



#### 2.通过sysctl命令修改

**sysctl命令**被用于在内核运行时动态地修改内核的运行参数，可用的内核参数在目录`/proc/sys`中。

```shell
sysctl(选项)(参数)
-n：打印值时不打印关键字；
-e：忽略未知关键字错误；
-N：仅打印名称；
-w：当改变sysctl设置时使用此项；
-p：从配置文件“/etc/sysctl.conf”加载内核参数设置；
-a：打印当前所有可用的内核参数变量和值；
-A：以表格方式打印当前所有可用的内核参数变量和值。
```

示例：

```shell
# 将/proc/sys/net/ipv4/conf/eth0/ignore_routes_with_linkdown参数设置为1
sysctl -w net.ipv4.conf.eth0.ignore_routes_with_linkdown=1
sysctl -w net.ipv4.conf.default.accept_redirects=0

# 从配置文件“/etc/sysctl.conf”加载内核参数设置；
sysctl -p
```



#### 3.修改/etc/sysctl.conf文件或/etc/sysctl.d下的文件

```shell
sudo vim /etc/sysctl.conf
	net.ipv4.conf.eth0.ignore_routes_with_linkdown = 1
	
# 或者
sudo vim /etc/sysctl.d/10-ipv4-custom.conf
	net.ipv4.conf.eth0.ignore_routes_with_linkdown = 1
	
service network restart
```





