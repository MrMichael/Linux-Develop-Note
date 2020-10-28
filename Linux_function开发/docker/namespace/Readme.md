### Namespace

Namespace，顾名思义，为不同的进程集合提供不同的「命名空间」，不同进程集合彼此不能访问其对应的「命名空间」，而「命名空间」其实就是其资源集合，它是 Linux 内核用来隔离内核资源的方式。

- 例如：进程 A 和进程 B 分别属于两个不同的 Namespace，那么进程 A 将可以使用 Linux 内核提供的所有 Namespace 资源：如独立的主机名，独立的文件系统，独立的进程编号等等。同样地，进程 B 也可以使用同类资源，但其资源与进程 A 使用的资源相互隔离，彼此无法感知。

Linux 内核提供了[ 7 种不同的 Namespace](http://man7.org/linux/man-pages/man7/namespaces.7.html)，由带有CLONE_NEW*标志的clone()所创建，如下所示：

- 前六种 namespace 正是实现容器必须的隔离技术，至于新提供的 Cgroup namespace 目前还没有被 docker 采用

| Namespace | `clone()` 使用的 flag | 所隔离的资源                 |
| --------- | --------------------- | ---------------------------- |
| IPC       | `CLONE_NEWIPC`        | System V IPC，POSIX 消息队列 |
| Network   | `CLONE_NEWNET`        | 网络设备、协议栈、端口等     |
| Mount     | `CLONE_NEWNS`         | 挂载点                       |
| PID       | `CLONE_NEWPID`        | 进程 ID                      |
| User      | `CLONE_NEWUSER`       | 用户和组 ID                  |
| UTS       | `CLONE_NEWUTS`        | 主机名和域名                 |
| Cgroup    | `CLONE_NEWCGROUP`     | Cgroup 根目录                |

用户可以在`/proc/$pid/ns`文件下看到本进程所属的`Namespace`的文件信息。例如PID为2704进程的情况如下图所示：

![](https://pic3.zhimg.com/80/v2-a7cec63ec33dd60377cf4d37bd94d5b4_720w.jpg)

- 其中 4026531839 表明是`Namespace`的ID，如果两个进程的`Namespace` ID相同表明两个进程同处于一个命名空间中。
- 即使 namespace 中的进程全部终结了，只要其软链接文件一直处于 open 状态，则 namespace 将一直存在；

