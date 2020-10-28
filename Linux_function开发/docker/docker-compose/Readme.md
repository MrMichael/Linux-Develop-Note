[TOC]



### 一、简介

[Docker Compose](https://docs.docker.com/compose/) 是用于定义和运行多容器Docker应用程序的工具。通过Compose，您可以使用YAML文件来配置应用程序的服务。然后，使用一个命令，就可以从配置中创建并启动所有服务。



使用Compose基本上是一个三步过程：

1. 使用定义您的应用环境，`Dockerfile`以便可以在任何地方复制。
2. 定义组成应用程序的服务，`docker-compose.yml` 以便它们可以在隔离的环境中一起运行。
3. Run `docker-compose up`and Compose启动并运行您的整个应用程序。



### 二、安装docker compose

基于Linux系统上安装

```shell
# 下载Docker Compose的当前稳定版本
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
$ sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

$ docker-compose --version
docker-compose version 1.25.4, build 8d51620a
```

卸载

```shell
sudo rm /usr/local/bin/docker-compose
```



### 三、docker compose命令说明 

[docker-compose命令说明](https://yeasy.gitbooks.io/docker_practice/compose/commands.html#up)

```shell
$ docker-compose --help
Define and run multi-container applications with Docker.

Usage:
  docker-compose [-f <arg>...] [options] [COMMAND] [ARGS...]
  docker-compose -h|--help

Options:
  -f, --file FILE             Specify an alternate compose file
                              (default: docker-compose.yml)
  -p, --project-name NAME     Specify an alternate project name
                              (default: directory name)
  --verbose                   Show more output
  --log-level LEVEL           Set log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
  --no-ansi                   Do not print ANSI control characters
  -v, --version               Print version and exit
  -H, --host HOST             Daemon socket to connect to

  --tls                       Use TLS; implied by --tlsverify
  --tlscacert CA_PATH         Trust certs signed only by this CA
  --tlscert CLIENT_CERT_PATH  Path to TLS certificate file
  --tlskey TLS_KEY_PATH       Path to TLS key file
  --tlsverify                 Use TLS and verify the remote
  --skip-hostname-check       Don't check the daemon's hostname against the
                              name specified in the client certificate
  --project-directory PATH    Specify an alternate working directory
                              (default: the path of the Compose file)
  --compatibility             If set, Compose will attempt to convert keys
                              in v3 files to their non-Swarm equivalent
  --env-file PATH             Specify an alternate environment file

Commands:
  build              Build or rebuild services
  config             Validate and view the Compose file
  create             Create services
  down               Stop and remove containers, networks, images, and volumes
  events             Receive real time events from containers
  exec               Execute a command in a running container
  help               Get help on a command
  images             List images
  kill               Kill containers
  logs               View output from containers
  pause              Pause services
  port               Print the public port for a port binding
  ps                 List containers
  pull               Pull service images
  push               Push service images
  restart            Restart services
  rm                 Remove stopped containers
  run                Run a one-off command
  scale              Set number of containers for a service
  start              Start services
  stop               Stop services
  top                Display the running processes
  unpause            Unpause services
  up                 Create and start containers
  version            Show the Docker-Compose version information
```



### 四、docker compose文件编写

[compose文件参考](https://docs.docker.com/compose/compose-file/)

Compose文件是一个[YAML](http://yaml.org/)文件，用于定义 [服务](https://docs.docker.com/compose/compose-file/#service-configuration-reference)， [网络](https://docs.docker.com/compose/compose-file/#network-configuration-reference)和 [卷](https://docs.docker.com/compose/compose-file/#volume-configuration-reference)。

- 服务定义包含应用于该服务启动的每个容器的配置，就像将命令行参数传递给 `docker run`一样。
- 网络和卷定义类似于 `docker network create`和`docker volume create`。
- docker-compose不需要重复指定Dockerfile中已指定的选项，例如 `CMD`、 `EXPOSE`、 `VOLUME`、 `ENV`等。

Compose文件格式是有多种版本的，例如1, 2, 2.x, 和 3.x。下表显示了哪些Compose文件版本支持特定的Docker版本。

| **Compose file格式** | **Docker Engine版本** |
| :------------------- | :-------------------- |
| 3.8                  | 19.03.0+              |
| 3.7                  | 18.06.0+              |
| 3.6                  | 18.02.0+              |
| 3.5                  | 17.12.0+              |
| 3.4                  | 17.09.0+              |
| 3.3                  | 17.06.0+              |
| 3.2                  | 17.04.0+              |
| 3.1                  | 1.13.1+               |
| 3.0                  | 1.13.0+               |
| 2.4                  | 17.12.0+              |
| 2.3                  | 17.06.0+              |
| 2.2                  | 1.13.0+               |
| 2.1                  | 1.12.0+               |
| 2.0                  | 1.10.0+               |
| 1.0                  | 1.9.1.+               |

所以compose文件的总体格式为：

```shell
version: "x.x"		# 版本号
services:				# 服务
  xxx:		# 服务名
  xxx:
	
networks:			 # 网络
  xxx:		# 网络名
  xxx:

volumes:			 # 卷
  xxx:		# 卷名
  xxx:
```





#### 1.文件结构和示例

官方compose示例文件

```shell
version: "3.8"
services:

  redis:
    image: redis:alpine
    ports:
      - "6379"
    networks:
      - frontend
    deploy:
      replicas: 2
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure

  db:
    image: postgres:9.4
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - backend
    deploy:
      placement:
        max_replicas_per_node: 1
        constraints:
          - "node.role==manager"

  vote:
    image: dockersamples/examplevotingapp_vote:before
    ports:
      - "5000:80"
    networks:
      - frontend
    depends_on:
      - redis
    deploy:
      replicas: 2
      update_config:
        parallelism: 2
      restart_policy:
        condition: on-failure

  result:
    image: dockersamples/examplevotingapp_result:before
    ports:
      - "5001:80"
    networks:
      - backend
    depends_on:
      - db
    deploy:
      replicas: 1
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure

  worker:
    image: dockersamples/examplevotingapp_worker
    networks:
      - frontend
      - backend
    deploy:
      mode: replicated
      replicas: 1
      labels: [APP=VOTING]
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 3
        window: 120s
      placement:
        constraints:
          - "node.role==manager"

  visualizer:
    image: dockersamples/visualizer:stable
    ports:
      - "8080:8080"
    stop_grace_period: 1m30s
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
    deploy:
      placement:
        constraints:
          - "node.role==manager"

networks:
  frontend:
  backend:

volumes:
  db-data:
```



#### 2.配置指令

[参考](https://zhuanlan.zhihu.com/p/139266041)

1）build

指定 `Dockerfile` 所在文件夹的路径,`Compose` 将会利用它自动构建镜像。

- context：指定文件夹路径（可以是包含 Dockerfile 的目录路径，也可以是 git 存储库的 url）
- dockerfile： 指定 `Dockerfile` 文件名
- args：为 `Dockerfile`中的变量赋值
- network：构建期间 `run` 指令要链接的网络
  - bridge、host、container、none
- cache_from：指定构建镜像时使用的缓存
- labels：通过标签向生成的镜像添加元数据
- sim_size：所构建容器的`/dev/shm`分区大小
- target：按照在 `Dockerfile` 中定义的方式构建指定的阶段

```shell
version: '3.8'
services:

  webapp:
    build:
      context: ./dir
      dockerfile: Dockerfile-alternate
      args:
        buildno: 1
      network: host 
      cache_from:
        - alpine:latest
        - corp/web_app:3.14
      labels:
        - "com.example.description=Accounting webapp"
        - "com.example.department=Finance"
        - "com.example.label-with-empty-value"
      shm_size: '2gb'
      target: prod
```

2）cap_add, cap_drop

添加或删除容器的内核能力

```shell
cap_add:
  - ALL  # 让容器拥有所有能力

cap_drop:
  - NET_ADMIN  # 移除 NET_ADMIN 功能
  - SYS_ADMIN  # 移除 SYS_ADMIN 功能
```

3）cgroup_parent

指定父 `cgroup` 组，意味着将继承该组的资源限制。

- 如：`cgroup_parent: m-executor-abcd`

4）command

覆盖容器启动后默认执行的命令。

- 如：`command: echo "hello world"`

5）configs

按服务授予对配置的访问权限

6）container_name

指定容器名称。默认将会使用 `项目名称_服务名称_序号` 这样的格式。

7）depends_on

指定服务之间的依赖关系，以便按顺序启动服务。

8）deploy

9）devices

指定设备映射关系。

```shell
devices:
  - "/dev/ttyUSB0:/dev/ttyUSB0"
```

10）dns

自定义 `DNS` 服务器，可以是单个值或列表。

```shell
dns:
  - 8.8.8.8
  - 114.114.114.114
```

11）dns_search

配置 `DNS` 搜索域，可以是单个值或列表。

```shell
dns_search:
  - dc1.example.com
  - dc2.example.com
```

12）entrypoint

重写默认入口点

- 如：`entrypoint: ["php", "-d", "memory_limit=-1", "vendor/bin/phpunit"]`

13）env_file

从文件中添加环境变量，可以是单个值或列表。env文件中每一行必须符合 `VAL=VAL` 格式。

```shell
env_file:
  - ./common.env
  - ./apps/web.env
  - /opt/secrets.env
```

14）environment

设置环境变量，只有名称的变量会自动解析为 Compose 运行主机上对应变量的值，可以用来防止泄露不必要的数据。

```shell
environment:
  - RACK_ENV=development
  - SESSION_SECRET
```

15）expose

在不将端口发布到主机的情况下公开端口（它们只能被链接的服务访问），只能指定内部端口。

```shell
expose:
 - "3000"
 - "8000"
```

16）extra_hosts

添加主机名映射，使用与 Docker 中的 `--add-host` 参数相同的值。

```shell
extra_hosts:
  - "somehost:162.242.195.82"
  - "otherhost:50.31.209.229"
```

会在启动后的服务容器的 `/etc/hosts` 文件中添加如下两条条目。

```shell
162.242.195.82  somehost
50.31.209.229   otherhost
```

17）image

指定要从哪个镜像启动容器。如果镜像在本地不存在，也没有指定了 `build`，`Compose` 将会尝试拉取这个镜像。

如果在 `build` 同时指定了 `image`，那么 Compose 会使用在 `image` 中指定的名字和标签来命名最终构建的镜像。

```shell
image: ubuntu
# 或
image: example-registry.com:4000/postgresql
# 或
image: a4bc65fd
```

18）init

用于转发信号和回收进程。

19）labels

为容器添加 Docker 元数据（metadata）信息。

```shell
labels:
  com.example.description: "Accounting webapp"
  com.example.department: "Finance"
  com.example.label-with-empty-value: ""
```

20）logging

配置日志选项。

```shell
logging:
  driver: syslog	# 指定一个日志驱动程序，syslog，json-file或none
  options:
    syslog-address: "tcp://192.168.0.42:123"
```

21）network_mode

设置网络模式。和 `docker run` 的 `--network` 参数一样。

```shell
network_mode: "bridge"
network_mode: "host"
network_mode: "none"
network_mode: "service:[service name]"
network_mode: "container:[container name/id]"
```

22）networks

配置容器连接的网络。

- aliases：别名，同一网络上的其他容器可以使用服务名称或这个别名连接到服务的一个容器，同一个服务在不同的网络上可以有不同的别名。

```shell
services:
	redis:
        networks:
             - new	# 对应到网络名
                aliases:
                  - alias1
          
networks:
  new:
```

23）pid

将 PID 模式设置为 `host` ，将与主机系统共享进程命名空间。

24）ports

暴露端口信息。使用 `HOST:CONTAINER` 格式，或者仅指定容器端口。

```shell
ports:
  - "3000"
  - "3000-3005"
  - "8000:8000"
  - "9090-9091:8080-8081"
  - "49100:22"
  - "127.0.0.1:8001:8001"
  - "127.0.0.1:5000-5010:5000-5010"
  - "6060:6060/udp"
  - "12400-12500:1240"
```

25）secrets

存储敏感数据，例如 `mysql` 服务密码。

```shell
services:
  redis:
    secrets:
      - my_secret
      - my_other_secret
secrets:
  my_secret:
    file: ./my_secret.txt
  my_other_secret:
    external: true
```

26）sysctls

配置容器内核参数。

```shell
sysctls:
  - net.core.somaxconn=1024
  - net.ipv4.tcp_syncookies=0
```

27）tmpfs

挂载一个临时文件系统到容器。

```shell
tmpfs:
  - /run
  - /tmp
```

28）volumes

数据卷所挂载路径设置。

- 设置为宿主机路径(`HOST:CONTAINER`)
- 设置数据卷名称(`VOLUME:CONTAINER`)，
- 设置访问模式 （`HOST:CONTAINER:ro`）。

```shell
volumes:
 - cache/:/tmp/cache
 - ~/configs:/etc/configs/:ro
 
# 路径为数据卷名称，必须在文件中配置数据卷。
services:
  my_sql:
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```

