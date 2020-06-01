

### 1.TCP通信

#### 1）TCP进程服务器

```c
/* server */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
//socket 所需的头文件
#include <sys/socket.h>
#include <netinet/in.h>

#include <arpa/inet.h>
#include <ctype.h>

//进程需要使用的头文件
#include <sys/types.h>
#include <unistd.h>
//waitpid函数需要的头文件
#include <sys/types.h>
#include <sys/wait.h>

#define MAXLINE	80
#define SERV_PORT	8000


int main(void)
{
	struct sockaddr_in servaddr, cliaddr;	//socket 地址结构体 服务端和客户端地址
	socklen_t cliaddr_len;
	int listenfd, connfd;//文件描述符
	char buf[MAXLINE];
	char str[INET_ADDRSTRLEN];
	int i,n;
	int status;
	
	pid_t pid;
	struct sigaction act_new;
	
	//创建流式套接字，即TCP socket
	listenfd = socket(AF_INET, SOCK_STREAM, 0);
	if (listenfd == -1) {
		fprintf(stderr, "create socket\n");
		exit(1);
	}
	
	//初始化socket地址
	bzero(&servaddr, sizeof(servaddr));
	servaddr.sin_family = AF_INET;//地址类型
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);//可监听任意ip地址
	servaddr.sin_port = htons(SERV_PORT);//可监听的网络端口
	//绑定地址与端口到套接字
	status = bind(listenfd, (struct sockaddr *)&servaddr, sizeof(servaddr) );
	if (status == -1) {
		fprintf(stderr, "bind\n");
		exit(1);
	}
	
	//设置socket为监听模式，最多允许有20个客户端处于连接待状态
	listen(listenfd, 20);
	if (status == -1) {
		fprintf(stderr, "listen\n");
		exit(1);
	}
	
	printf("Accepting connections ...\n");
	
	while (1) {
		cliaddr_len = sizeof(cliaddr);
		//服务端阻塞等待客户端连接
		connfd = accept(listenfd, (struct sockaddr *)&cliaddr, &cliaddr_len);
		
		//当有新的客户端连接时，fork出一个新进程来管理接收
		pid = fork();
		if (pid == -1) {
			perror("call to fork");
			exit(1);
		} else if (pid == 0) {
			//child
			close(listenfd);
			
			printf("connect to %s at PORT %d\n", inet_ntop(AF_INET, &cliaddr.sin_addr, str, sizeof(str)), ntohs(cliaddr.sin_port));
			
			while (1) {
				//通过文件描述符读取数据  阻塞等待
				n = read(connfd, buf, MAXLINE);
				if (n == 0) {
					printf("disconnect to %s at PORT %d\n", inet_ntop(AF_INET, &cliaddr.sin_addr, str, sizeof(str)), ntohs(cliaddr.sin_port));
					exit(0);
				}
				//客户端的端口是随机分配的
				printf("received from %s at PORT %d\n", inet_ntop(AF_INET, &cliaddr.sin_addr, str, sizeof(str)), ntohs(cliaddr.sin_port));
				
				for (i = 0; i < n; i++) {
					buf[i] = toupper(buf[i]);//将小写变大写
				}
				//通过文件描述符写入数据
				write(connfd, buf, n);
			}
			close(connfd);
			
		} else {
			//parent
			
			close(connfd);
		}

	}
	
	close(listenfd);
}
```

#### 2）TCP客户端

```c
/* client */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
//socket 所需的头文件
#include <sys/socket.h>
#include <netinet/in.h>

#include <arpa/inet.h>
#include <ctype.h>

#define MAXLINE	80
#define SERV_PORT	8000

//将client改为交互式输入

int main(int argc, char *argv[])
{
	struct sockaddr_in servaddr;
	char buf[MAXLINE];
	int sockfd; //文件描述符
	int n;
	
	//创建流式套接字，即TCP socket
	sockfd = socket(AF_INET, SOCK_STREAM, 0);
	if (sockfd == -1) {
		fprintf(stderr, "create socket\n");
		exit(1);
	}
	
	//初始化socket地址
	bzero(&servaddr, sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	inet_pton(AF_INET, "127.0.0.1", &servaddr.sin_addr);
	servaddr.sin_port = htons(SERV_PORT);
	
	//客户端请求连接服务器
	connect(sockfd, (struct sockaddr *)&servaddr, sizeof(servaddr));
	
	while (1) {
		if (fgets(buf, MAXLINE, stdin) != NULL) {
			//通过文件描述符写入数据 
			write(sockfd, buf, strlen(buf));
			
			//通过文件描述符读取数据  阻塞等待
			n = read(sockfd, buf, MAXLINE);
			if (n == 0) {
				printf("the other side has been closed.\n");
			} else {
				printf("Response from server:\n");
				write(STDOUT_FILENO, buf, n);
			}
		}
	}

	close(sockfd);
	
	return 0;
}
```



### 2.UDP通信

#### 1）UDP服务器

```c
/* server */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
//socket 所需的头文件
#include <sys/socket.h>
#include <netinet/in.h>

#include <arpa/inet.h>
#include <ctype.h>

#define MAXLINE 80
#define SERV_PORT 8000

int main(void)
{
	struct sockaddr_in servaddr, cliaddr;	//socket 地址结构体 服务端和客户端地址
	socklen_t cliaddr_len;
	int sockfd;//文件描述符
	char buf[MAXLINE];
	char str[INET_ADDRSTRLEN];
	int i,n;
	int status;
	
	//创建块式套接字，即UDP socket
	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	if (sockfd == -1) {
		fprintf(stderr, "create socket\n");
		exit(1);
	}
	
	//初始化socket地址
	bzero(&servaddr, sizeof(servaddr));
	servaddr.sin_family = AF_INET;//地址类型
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);//可监听任意ip地址
	servaddr.sin_port = htons(SERV_PORT);//可监听的网络端口
	//绑定地址与端口到套接字
	status = bind(sockfd, (struct sockaddr *)&servaddr, sizeof(servaddr) );
	if (status == -1) {
		fprintf(stderr, "bind\n");
		exit(1);
	}
	
	printf("Accepting connections ...\n");
	
	while (1) {
		cliaddr_len = sizeof(cliaddr);
		//阻塞等待客户端数据到来
		n = recvfrom(sockfd, buf, MAXLINE, 0, (struct sockaddr *)&cliaddr, &cliaddr_len);
		if (n == -1) {
			fprintf(stderr, "recvfrom error\n");
			exit(1);
		}
		printf("received from %s at PORT %d\n", inet_ntop(AF_INET, &cliaddr.sin_addr, str, sizeof(str)), ntohs(cliaddr.sin_port));
			
		for (i = 0; i < n; i++) {
			buf[i] = toupper(buf[i]);//小写字母转大写
		}
		
		n = sendto(sockfd, buf, n, 0, (struct sockaddr *)&cliaddr, sizeof(cliaddr));
		if (n == -1) {
			fprintf(stderr, "sendto error\n");
			exit(1);
		}
	}
	
}
```

#### 2）UDP客户端

```c
/* client */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
//socket 所需的头文件
#include <sys/socket.h>
#include <netinet/in.h>

#include <arpa/inet.h>
#include <ctype.h>

#define MAXLINE 80
#define SERV_PORT 8000

int main(int argc, char *argv[])
{
	struct sockaddr_in servaddr;
	int sockfd, n;
	char buf[MAXLINE];
	char str[INET_ADDRSTRLEN];
	socklen_t servaddr_len;
	
	//创建UDP socket
	sockfd = socket(AF_INET, SOCK_DGRAM, 0);

	bzero(&servaddr, sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	inet_pton(AF_INET, "127.0.0.1", &servaddr.sin_addr);
	servaddr.sin_port = htons(SERV_PORT);
	
	while (1) {
		if (fgets(buf, MAXLINE, stdin) != NULL) {
			//通过文件描述符发送数据
			n = sendto(sockfd, buf, strlen(buf), 0, (struct sockaddr *)&servaddr, sizeof(servaddr));
			if (n == -1) {
				fprintf(stderr, "sendto error\n");
				exit(1);
			}
			
			//通过文件描述符接收数据
			n = recvfrom(sockfd, buf, MAXLINE, 0, NULL, 0);
			if (n == -1) {
				fprintf(stderr, "recvfrom error\n");
				exit(1);
			}
			
			write(STDOUT_FILENO, buf, n);

		}
	}
	close(sockfd);
	
	return 0;
}
```


