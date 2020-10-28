[TOC]

[RabbitMQ Tutorials](https://www.rabbitmq.com/getstarted.html)



### 一、简介

RabbitMQ是由erlang语言开发，基于AMQP（Advanced Message Queue 高级消息队列协议）协议实现的消息队列，它是一种应用程序之间的通信方法，消息队列在分布式系统开发中应用非常广泛。

RabbitMQ是消息代理：它接受并转发消息。可以将其视为邮局：将要发布的邮件放在邮箱中时，可以确保邮递员最终将邮件传递给收件人。以此类推，RabbitMQ是一个邮箱，一个邮局和一个邮递员。

![img](https://images2018.cnblogs.com/blog/1076976/201803/1076976-20180320095644368-1458394907.jpg)



#### 1.组成部分

![](https://pic4.zhimg.com/80/v2-8babc9673188319aa996bedf18be77aa_720w.jpg)

- Broker：消息队列服务进程，此进程包括两个部分：Exchange和Queue。
- Exchange：消息队列交换机，按一定的规则将消息路由转发到某个队列，对消息进行过滤。
  - exchange的作用就是类似路由器，routing key 就是路由键，服务器会根据路由键将消息从交换器路由到队列上去。
  - exchange属性
    - exchange：名称
    - type：类型
      - direct：将消息中的`Routing key`与该`Exchange`关联的所有`Binding`中的`Routing key`进行比较，如果相等，则发送到该`Binding`对应的`Queue`中。
      - fanout：广播，直接将消息转发到所有`binding`的对应`queue`中，这种`exchange`在路由转发的时候，忽略`Routing key`。
      - topic：将消息中的`Routing key`与该`Exchange`关联的所有`Binding`中的`Routing key`进行对比，如果匹配上（支持正则表达式）了，则发送到该`Binding`对应的`Queue`中。
      - headers：将消息中的`headers`与该`Exchange`相关联的所有`Binging`中的参数进行匹配，如果匹配上了，则发送到该`Binding`对应的`Queue`中。
    - durable：是否持久化，RabbitMQ关闭后，没有持久化的Exchange将被清除
    - autoDelete：是否自动删除，如果没有与之绑定的Queue，直接删除
    - internal：是否内置的，如果为true，只能通过Exchange到Exchange
    - arguments：结构化参数
- Queue：消息队列，存储消息的队列，消息到达队列并转发给指定的消费方。
  - push模式：通过AMQP的basic.consume命令订阅，有消息会自动接收，吞吐量高
  - pull模式：通过AMQP的bsaic.get命令
  - queue属性
    - queue：名称
    - durable：是否持久化，RabbitMQ关闭后，没有持久化的queue将被清除
    - autoDelete：是否自动删除，如果没有与之绑定的Queue，直接删除
    - exclusive：是否专属，一个连接下面的多个信道是可见的，对于其他连接是不可见的，连接断开后,该队列会被删除（设置成了持久化也会删除）。
    - arguments：结构化参数
- Producer：消息生产者，即生产方客户端，生产方客户端将消息发送到MQ。
- Consumer：消息消费者，即消费方客户端，接收MQ转发的消息。



#### 2.消息发布接收流程

- 发送消息
  - 生产者和Broker建立TCP连接。
  - 生产者和Broker建立通道。
    - 通道是建立在TCP连接上的虚拟连接，这个TCP被多个线程共享，每个线程对应一个信道，信道在rabbit都有唯一的ID。
    - 类似概念：TCP是电缆，通道就是里面的光纤，每个光纤都是独立的，互不影响。
  - 生产者通过通道消息发送给Broker，由Exchange将消息进行转发。
  - Exchange根据所属类型将消息转发到指定的Queue（队列）

- 接收消息
  - 消费者和Broker建立TCP连接
  - 消费者和Broker建立通道
  - 消费者监听指定的Queue（队列）
  - 当有消息到达Queue时Broker默认将消息推送给消费者。
  - 消费者接收到消息。



### 二、安装RabbitMQ服务器

[Downloading and Installing RabbitMQ](https://www.rabbitmq.com/download.html)

安装RabbitMQ需要运行Erlang/OTP，并保持版本匹配。

支持的distribution list

- focal for Ubuntu 20.04
- bionic for Ubuntu 18.04
- xenial for Ubuntu 16.04
- buster for Debian Buster
- stretch for Debian Stretch

component是指Erlang/OTP 版本

- 23.x
- 22.3.x
- 21.3.x
- 20.3.x
- master (24.x)
- R16B03 (16.x)



#### 1.在ubuntu下直接安装

```shell
sudo apt-get update -y
sudo apt-get install curl gnupg -y

#安装RabbitMQ签名密钥 
curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc | sudo apt-key add -

# 使用密钥服务器
sudo apt-key adv --keyserver "hkps://keys.openpgp.org" --recv-keys "0x0A9AF2115F4687BD29803A206B73A36E6026DFCA"

sudo apt-get install apt-transport-https

# 添加源列表文件
sudo vim /etc/apt/sources.list.d/bintray.erlang.list
	## Installs the latest Erlang 23.x release.
    ## Change component to "erlang-22.x" to install the latest 22.x version.
    ## "bionic" as distribution name should work for any later Ubuntu or Debian release.
    ## See the release to distribution mapping table in RabbitMQ doc guides to learn more.
    deb https://dl.bintray.com/rabbitmq-erlang/debian bionic erlang
    ## Installs latest RabbitMQ release
    deb https://dl.bintray.com/rabbitmq/debian bionic main
    
# 安装rabbitmq-server软件包
sudo apt-get update -y
sudo apt-get install rabbitmq-server -y --fix-missing
```

ubutnu rabbitmq常用命令

```shell
# 启动rabbitmq服务
service rabbitmq-server restart

# 启动rabbitm
rabbitmq-service start
# 关闭rabbitmq
rabbitmq-service stop

# 列举所有插件
rabbitmq-plugins list
# 启动插件
rabbitmq-plugins enable rabbitmq_management
# 关闭动插件
rabbitmq-plugins disable rabbitmq_management

# 查看所有的队列
rabbitmqctl list_queues
# 清除所有的队列
rabbitmqctl reset
# 查看用户
rabbitmqctl list_users
```



#### 2.使用docker安装【推荐】

[docker hub镜像仓库地址](https://hub.docker.com/)

- rabbitmq：镜像未配有控制台

- rabbitmq:management：镜像配有控制台

```shell
# 拉取RabbitMQ镜像
$ sudo docker pull rabbitmq:management
Status: Downloaded newer image for rabbitmq:management
docker.io/library/rabbitmq:management

$ sudo docker images |grep rabbit
rabbitmq                                                  management                                 5726af297dd4        5 days ago          187MB

# 将RabbitMQ 镜像放入容器中（docker create）, 然后将容器启动(docker start)
$ sudo docker run --name rabbitmq -d -p 15672:15672 -p 5672:5672 rabbitmq:management
	# d 后台运行容器；
	# --name 指定容器名；
	# -p 指定服务运行的端口（5672：应用访问端口；15672：控制台Web端口号）；

$ sudo docker ps
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                                                                                                         NAMES
85a2ce7d3dfb        rabbitmq:management   "docker-entrypoint.s…"   6 seconds ago       Up 5 seconds        4369/tcp, 5671/tcp, 0.0.0.0:5672->5672/tcp, 15671/tcp, 15691-15692/tcp, 25672/tcp, 0.0.0.0:15672->15672/tcp   rabbitmq

# 停止 RabbitMQ 容器
$ sudo docker stop rabbitmq

# 启动 RabbitMQ 容器
$ sudo docker start rabbitmq
```

控制台信息

- 启动容器后，可以浏览器中访问[http://localhost:15672](http://localhost:15672/)来查看控制台信息。

  - `RabbitMQ`默认的用户名：`guest`，密码：`guest`

  ![](https://img-blog.csdnimg.cn/20181207114148372.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80Mjc0MDI2OA==,size_16,color_FFFFFF,t_70)



### 三、主机使用rabbitmq 服务器

```shell
# 启动服务器
service rabbitmq-server start
```

#### 1.端口访问

RabbitMQ节点绑定到端口（开放服务器TCP套接字），以便接受客户端和CLI工具连接。需要确保可以访问以下端口：

- `4369`：[epmd](http://erlang.org/doc/man/epmd.html)，RabbitMQ节点和CLI工具使用的对等发现服务
- `5672、5671`：由不带TLS和带TLS的AMQP 0-9-1和1.0客户端使用
- `25672`：用于节点间和CLI工具通信（Erlang分发服务器端口），并从动态范围分配（默认情况下限制为单个端口，计算为AMQP端口+ 20000）。除非确实需要这些端口上的外部连接，否则这些端口不应公开。
- 35672-35682：由CLI工具用于与节点进行通信，并从动态范围分配（通过服务器分发端口+ 10010计算为服务器分发端口+ 10000）。
- `15672`：[HTTP API](https://www.rabbitmq.com/management.html)客户端，[管理UI](https://www.rabbitmq.com/management.html)和[Rabbitmqadmin](https://www.rabbitmq.com/management-cli.html) （仅在启用了[管理插件的](https://www.rabbitmq.com/management.html)情况下）
- 61613、61614：不带TLS和带TLS的[STOMP客户端](https://stomp.github.io/stomp-specification-1.2.html)（仅在启用[STOMP插件的](https://www.rabbitmq.com/stomp.html)情况下）
- 1883、8883 ：（不带和带有TLS的[MQTT客户端](http://mqtt.org/)，如果启用了[MQTT插件](https://www.rabbitmq.com/mqtt.html)
- 15674：STOMP-over-WebSockets客户端（仅在启用了[Web STOMP插件的](https://www.rabbitmq.com/web-stomp.html)情况下）
- 15675：MQTT-over-WebSockets客户端（仅当启用了[Web MQTT插件时](https://www.rabbitmq.com/web-mqtt.html)）
- 15692：Prometheus指标（仅在启用[Prometheus插件的](https://www.rabbitmq.com/prometheus.html)情况下）



#### 2.调整Linux上系统限制

消息队列在linux系统中运行主要受到两个限制：

- 操作系统内核允许的最大打开文件数（fs.file-max）

  - 修改配置文件/etc/systemd/system/rabbitmq-server.service.d/limits.conf，设置LimitNOFILE=64000。

  - 修改Docker包含的内核限制：/etc/docker/daemon.json

    ```json
    {
       “ default-ulimits”：{
         “ nofile”：{
           “ Name”：“ nofile”，
           “ Hard”：64000，
           “ Soft”：64000 
        } 
      } 
    }
    ```

- 每个用户的限制打开文件数（ulimit -n）

调整系统限制和内核参数，才能处理相当数量的并发连接和队列。建议在生产环境中为用户Rabbitmq至少允许65536个文件描述符。

验证内核限制

```shell
$ rabbitmqctl status

# 查看进程的限制
$ cat /proc/$RABBITMQ_BEAM_PROCESS_PID/limits
```



### 四、使用RabbitMQ客户端

#### 1.RabbitMQ支持的客户端

[Clients Libraries and Developer Tools](https://www.rabbitmq.com/devtools.html)

RabbitMQ支持以下语言的客户端

- [Java and Spring](https://www.rabbitmq.com/devtools.html#java-dev)
- [.NET](https://www.rabbitmq.com/devtools.html#dotnet-dev)
- [Ruby](https://www.rabbitmq.com/devtools.html#ruby-dev)
- [Python](https://www.rabbitmq.com/devtools.html#python-dev)
- [PHP](https://www.rabbitmq.com/devtools.html#php-dev)
- [JavaScript and Node](https://www.rabbitmq.com/devtools.html#node-dev)
- [Objective-C and Swift](https://www.rabbitmq.com/devtools.html#objc-swift-dev)
- [Rust](https://www.rabbitmq.com/devtools.html#rust-dev)
- [Crystal](https://www.rabbitmq.com/devtools.html#crystal-dev)
- [C and C++](https://www.rabbitmq.com/devtools.html#c-dev)
- [Go](https://www.rabbitmq.com/devtools.html#go-dev)
- [iOS and Android](https://www.rabbitmq.com/devtools.html#ios-android)



#### 2.RabbitMQ客户端的工作模式

1）简单模式(hello world)

不使用Exchange。

![img](https://upload-images.jianshu.io/upload_images/17556383-910912250474b9f1.png?imageMogr2/auto-orient/strip|imageView2/2/w/485/format/webp)

- 一个生产者，一个消费者。

2）工作队列（Work queues）

不使用Exchange。

![img](https://upload-images.jianshu.io/upload_images/17556383-e169b766cd67560f.png?imageMogr2/auto-orient/strip|imageView2/2/w/502/format/webp)

- 一个生产者，多个消费者
- 一条消息只会被一个消费者接收；
- 采用轮询的方式将消息是平均发送给消费者的；
- 消费者在处理完某条消息后，才会收到下一条消息。

3）发布/订阅（Publish/Subscribe）

使用Exchange，且类型为fanout。

![img](https://upload-images.jianshu.io/upload_images/17556383-36cd63df3fa0f093.png?imageMogr2/auto-orient/strip|imageView2/2/w/813/format/webp)

- 每个消费者监听自己的队列。
- 生产者将消息发给broker，由交换机将消息转发到绑定此交换机的每个队列，每个绑定交换机的队列都将接收到消息。

4）路由模式（Routing）

使用Exchange，且类型为direct。

![img](https://upload-images.jianshu.io/upload_images/17556383-3a100c6d7270a65d.png?imageMogr2/auto-orient/strip|imageView2/2/w/802/format/webp)

- 每个消费者监听自己的队列，并且设置routing key。
- 生产者将消息发给交换机，由交换机根据routing key来转发消息到指定的队列。

5）主题模式（Topics）

使用Exchange，且类型为topic。

![img](https://upload-images.jianshu.io/upload_images/17556383-7f0d87d87ee2d578.png?imageMogr2/auto-orient/strip|imageView2/2/w/769/format/webp)

主题模式应该算是路由模式的一种，也是通过 `routing_key` 来分发，只不过是 `routing_key` 支持了正则表达式，更加灵活。

- 星号井号代表通配符
- 星号代表多个单词，井号代表一个单词
- 路由功能添加模糊匹配
- 消息产生者产生消息,把消息交给交换机
- 交换机根据key的规则模糊匹配到对应的队列,由队列的监听消费者接收消息消费

6）RPC

![img](https://upload-images.jianshu.io/upload_images/17556383-b9d3dcdea76db452.png?imageMogr2/auto-orient/strip|imageView2/2/w/790/format/webp)

RPC即客户端远程调用服务端的方法 ，使用MQ可以实现RPC的异步调用，基于Direct交换机实现。

- 客户端即是生产者也是消费者，向RPC请求队列发送RPC调用消息，同时监听RPC响应队列。
- 服务端监听RPC请求队列的消息，收到消息后执行服务端的方法，得到方法返回的结果。
- 服务端将RPC方法 的结果发送到RPC响应队列。
- 客户端（RPC调用方）监听RPC响应队列，接收到RPC调用结果。





#### 3.Go RabbitMQ 客户端使用

[Go code for RabbitMQ tutorials](https://github.com/rabbitmq/rabbitmq-tutorials)

当前主要介绍Go语言的Rabbit 客户端使用。

- 获取Go RabbitMQ客户端库

  ```go
  go get github.com/streadway/amqp
  ```

  [package amqp spi说明](https://godoc.org/github.com/streadway/amqp)

- 发送消息（生产者）

  ![](https://www.rabbitmq.com/img/tutorials/sending.png)

  ```go
  // 1.import the library
  package main
  import (
    "log"
    "github.com/streadway/amqp"
  )
  
  func failOnError(err error, msg string) {
  	if err != nil {
  		log.Fatalf("%s: %s", msg, err)
  	}
  }
  
  func main() {
      // 2.connect to RabbitMQ server
      //该连接抽象了套接字连接，并处理协议版本协商和认证等。
  	conn, err := amqp.Dial("amqp://guest:guest@localhost:5672/")
  	failOnError(err, "Failed to connect to RabbitMQ")
  	defer conn.Close()
  
      // 3.create a channel
  	ch, err := conn.Channel()
  	failOnError(err, "Failed to open a channel")
  	defer ch.Close()
  
      // 4.使用channel声明一个队列
  	q, err := ch.QueueDeclare(
  		"hello", // name
  		false,   // durable
  		false,   // delete when unused
  		false,   // exclusive
  		false,   // no-wait
  		nil,     // arguments
  	)
  	failOnError(err, "Failed to declare a queue")
  
      // 5.使用通道发布消息到队列中
  	body := "Hello World!"
  	err = ch.Publish(
  		"",     // exchange
  		q.Name, // routing key，将q.Name作为routing key
  		false,  // mandatory
  		false,  // immediate
  		amqp.Publishing{
  			ContentType: "text/plain",
  			Body:        []byte(body),
  		})
  	log.Printf(" [x] Sent %s", body)
  	failOnError(err, "Failed to publish a message")
  }
  ```

- 接收消息（消费者）

  ![](https://www.rabbitmq.com/img/tutorials/receiving.png)

  ```go
  // 1.import the library
  package main
  import (
  	"log"
  	"github.com/streadway/amqp"
  )
  
  func failOnError(err error, msg string) {
  	if err != nil {
  		log.Fatalf("%s: %s", msg, err)
  	}
  }
  
  func main() {
      // 2.connect to RabbitMQ server
  	conn, err := amqp.Dial("amqp://guest:guest@localhost:5672/")
  	failOnError(err, "Failed to connect to RabbitMQ")
  	defer conn.Close()
  
      // 3.create a channel
  	ch, err := conn.Channel()
  	failOnError(err, "Failed to open a channel")
  	defer ch.Close()
  
       // 4.使用channel声明一个队列
  	q, err := ch.QueueDeclare(
  		"hello", // name
  		false,   // durable
  		false,   // delete when unused
  		false,   // exclusive
  		false,   // no-wait
  		nil,     // arguments
  	)
  	failOnError(err, "Failed to declare a queue")
  
      //5. 接收(消费)队列消息
  	msgs, err := ch.Consume(
  		q.Name, // queue
  		"",     // consumer
  		true,   // auto-ack
  		false,  // exclusive
  		false,  // no-local
  		false,  // no-wait
  		nil,    // args
  	)
  	failOnError(err, "Failed to register a consumer")
  
  	forever := make(chan bool)
  
  	go func() {
          //6. 打印队列消息的内容
  		for d := range msgs {
  			log.Printf("Received a message: %s", d.Body)
  		}
  	}()
  
  	log.Printf(" [*] Waiting for messages. To exit press CTRL+C")
  	<-forever
  }
  ```

  

