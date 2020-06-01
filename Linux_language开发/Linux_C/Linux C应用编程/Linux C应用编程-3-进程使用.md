### 1.fork产生子进程

![image](http://upload-images.jianshu.io/upload_images/15877540-16a162371e59f99b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```c
    
#include <stdio.h>
#include <stdlib.h>
//进程需要使用的头文件
#include <sys/types.h>
#include <unistd.h>
//waitpid函数需要的头文件
#include <sys/types.h>
#include <sys/wait.h>

int main(void)
{
	pid_t pid;
	char *message;
	int n = 1;
	int count = 0;
	
	pid = fork();
	if (pid < 0) {
		perror("fork failed");
		exit(1);
	}
	
	//fork成功以后，子进程和父进程都会执行下面的代码
	//后续变量都是独立的，操作互不影响
	if (pid == 0) {
		//fork函数对子进程返回0
		printf("child id:%d, parent id:%d\r\n",getpid(), getppid());
		message = "This is the child";
		n = 6;
	} else {
		//fork函数对父进程返回子进程id
		printf("parent id:%d, child id:%d\r\n",getpid(), pid);
		message = "This is the parent";
		n = 3;
	}
	
	for (; n > 0; n--) {
		count++;
		printf("%s,count:%d\r\n",message, count);
		sleep(1);
	}
	
	if (pid > 0) {
		int stat_val;
		waitpid(pid, &stat_val, 0);
		//如果子进程是正常终止的，WIFEXITED取出的字段值非零
		if (WIFEXITED(stat_val)) {
			//WEXITSTATUS取出的字段值就是子进程的退出状态
			printf("Child exited with code %d\n", WEXITSTATUS(stat_val));
		} else if (WIFSIGNALED(stat_val)) {
			//如果子进程是收到信号而异常终止的，WIFSIGNALED取出的字段值非零
			//WTERMSIG取出的字段值就是信号的编号
			printf("Child terminated abnormally, signal %d\n", WTERMSIG(stat_val));
		}
	}
	
	return 0;
}
```

### 2.exec族函数

当进程调用一种`exec`函数时，该进程的用户空间代码和数据完全被新程序替换，从新程序的启动例程开始执行。调用`exec`并不创建新进程，所以调用`exec`前后该进程的id并未改变。

```c
#include <unistd.h>

int execl(const char *path, const char *arg, ...);
int execlp(const char *file, const char *arg, ...);
int execle(const char *path, const char *arg, ..., char *const envp[]);
int execv(const char *path, char *const argv[]);
int execvp(const char *file, char *const argv[]);
int execve(const char *path, char *const argv[], char *const envp[]);
```

- 不带字母p（表示path）的`exec`函数第一个参数必须是程序的相对路径或绝对路径
- 带有字母l（表示list）的`exec`函数要求将新程序的每个命令行参数都当作一个参数传给它，命令行参数的个数是可变的，最后一个可变参数是`NULL`
- 对于带有字母v（表示vector）的函数，应该先构造一个指向各参数的指针数组，然后将该数组的首地址当作参数传给它，数组中的最后一个指针也应该是`NULL`
- 对于以e（表示environment）结尾的`exec`函数，可以把一份新的环境变量表传给它

```c
#include <stdio.h>
#include <stdlib.h>

#include <unistd.h>

//命令行参数
char *const ps_argv[] = {"ps", "-o", "pid,ppid,pgrp,session,tpgid,comm", NULL};
//环境变量
char *const ps_envp[] = {"PATH=/bin:/usr/bin", "TERM=console", NULL};

int main(void)
{
	//ps是linux自带的应用程序
	//"ps", "-o", "pid,ppid,pgrp,session,tpgid,comm", NULL 都是命令行参数
	//这相当于在bash命令行输入：ps -o pid,ppid,pgrp,session,tpgid,comm
	
    //绝对路径，通过列表表示命令行参数
	//execl("/bin/ps", "ps", "-o", "pid,ppid,pgrp,session,tpgid,comm", NULL);
	
    //自动搜索路径，通过列表表示命令行参数
	//execlp("ps", "ps", "-o", "pid,ppid,pgrp,session,tpgid,comm", NULL);
	
    //绝对路径，通过列表表示命令行参数，传入环境变量
	//execle("/bin/ps", "ps", "-o", "pid,ppid,pgrp,session,tpgid,comm", NULL, ps_envp);
	
    //自动搜索路径，通过列表表示命令行参数，传入环境变量
	//这个函数在ubuntu中不存在
	//execlpe("ps", "ps", "-o", "pid,ppid,pgrp,session,tpgid,comm", NULL, ps_envp);
	
    //绝对路径，通过指针数组表示命令行参数
	//execv("/bin/ps", ps_argv);
	
    //自动搜索路径，通过指针数组表示命令行参数
	//execvp("ps", ps_argv);
	
    //自动搜索路径，通过指针数组表示命令行参数，传入环境变量
	execve("/bin/ps", ps_argv, ps_envp);
	
	//由于exec函数只有错误返回值，只要返回了一定是出错
	//所以不需要判断它的返回值，直接在后面调用perror即可。
	perror("exec ps");
	exit(1);
	
	return 0;
}
```

### 3.wait和waitpid函数

父进程可以调用`wait`或`waitpid`等待子进程终止，然后彻底清除掉这个进程。

```c
#include <sys/types.h>
#include <sys/wait.h>

pid_t wait(int *status);
pid_t waitpid(pid_t pid, int *status, int options);
/*
wait等待第一个终止的子进程，而waitpid可以通过pid参数指定等待哪一个子进程
若调用成功则返回清理掉的子进程id，若调用出错则返回-1。
*/
```

### 4.进程间通信

每个进程各自有不同的用户地址空间，任何一个进程的全局变量在另一个进程中都看不到。进程之间要交换数据`必须通过内核`，在内核中开辟一块缓冲区，进程1把数据从用户空间拷到内核缓冲区，进程2再从内核缓冲区把数据读走，内核提供的这种机制称为进程间通信。

![image](http://upload-images.jianshu.io/upload_images/15877540-91146a0c714f3491.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 1）通过匿名管道

```c
#include <unistd.h>

int pipe(int filedes[2]);
```

- 调用`pipe`函数时在内核中开辟一块缓冲区（称为管道）用于通信，它有一个读端一个写端，然后通过`filedes`参数传出给用户程序两个文件描述符，`filedes[0]`指向管道的读端，`filedes[1]`指向管道的写端（就像0是标准输入1是标准输出一样）。
- 仅可用于父进程与子进程之间通信

![image](http://upload-images.jianshu.io/upload_images/15877540-b207bd8968b70af2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```c
#include <stdio.h>
#include <stdlib.h>
//进程需要使用的头文件
#include <sys/types.h>
#include <unistd.h>
//waitpid函数需要的头文件
#include <sys/types.h>
#include <sys/wait.h>

#define MAXLINE 80

int main(void)
{
	int n;
	int fd[2], fd2[2];
	pid_t pid;
	char line[MAXLINE];
	
    //创建管道1，用于父线程写、子线程读
	if (pipe(fd) < 0) {
		perror("pipe fd");
		exit(1);
	}
	
    //创建管道2，用于父线程读、子线程写
	if (pipe(fd2) < 0) {
		perror("pipe fd2");
		exit(1);
	}
	
	if ((pid = fork()) < 0) {
		perror("fork");
		exit(1);
	}
	
	if (pid == 0) {
		//child
		close(fd[1]); //关闭写端
		n = read(fd[0], line, MAXLINE);
		write(STDOUT_FILENO, "child pipe read:", 16);
		write(STDOUT_FILENO, line, n);
		
		close(fd2[0]); //关闭读端
		write(STDOUT_FILENO, "child pipe write\n", 17);
		write(fd2[1], "hello parent\r\n", 14);
		
	} else {
		//parent
		close(fd[0]); //关闭读端
		write(STDOUT_FILENO, "parent pipe write\n", 18);
		write(fd[1], "hello child\r\n", 13);
		
		close(fd2[1]); //关闭写端
		n = read(fd2[0], line, MAXLINE);
		write(STDOUT_FILENO, "parent pipe read:", 17);
		write(STDOUT_FILENO, line, n);
		
		wait(NULL);
	}
	
	return 0;
}
```

#### 2）通过FIFO文件

- 在文件系统中用`mkfifo`命令创建一个FIFO文件，FIFO文件在磁盘上没有数据块，仅用来标识内核中的一条通道，各进程可以打开这个文件进行`read`/`write`，实际上是在读写内核通道，从而实现进程间通信。
- 能让所有进程相互通信

```c
#include <stdio.h>
#include <stdlib.h>

//进程需要使用的头文件
#include <sys/types.h>
#include <unistd.h>
//wait函数需要的头文件
#include <sys/types.h>
#include <sys/wait.h>
//命名管道需要用的头文件
#include <sys/stat.h>
//文件操作需要的头文件
#include <fcntl.h>

char fifoname[] = {"./pipefifo"};

int main(void)
{
	int fd;
	pid_t pid;
	char buf[20];
	int n;
	
	if (access(fifoname, F_OK) < 0) {
		//FIFO和socket都是特殊文件
		//FIFO也只支持单向传输，双向传输需要使用两个管道
		if (mkfifo(fifoname, 0777) < 0 ) {
			perror("mkfifo");
			exit(1);
		}
		
		//创建普通文件也可以达到进程间通信的效果，就是对文件进行读写
		//使用普通文件传输会有数据残留
		/*fd = creat(fifoname, 0777);
		if (fd < 0) {
			perror("creat");
			exit(1);
		}
		close(fd);*/
	}
	
	if((pid = fork()) < 0) {
		perror("fork");
		exit(1);
	}
	
	if (pid == 0) {
		//child
		fd = open(fifoname, O_RDWR);
		if (fd < 0) {
			perror("fork");
			exit(1);
		}
		
		n = read(fd, buf, 20);
		write(STDOUT_FILENO, "child get:", 10);
		write(STDOUT_FILENO, buf, n);
	} else {
		//parent
		fd = open(fifoname, O_RDWR);
		if (fd < 0) {
			perror("fork");
			wait(NULL);
			exit(1);
		}
		write(STDOUT_FILENO, "parent:hello child\r\n", 20);
		write(fd, "hello child\r\n", 13);
		
		wait(NULL);
	}
	return 0;
}
```

普通文件是不能用于进程间通信的，因为不是通过内核进行数据交互。

#### 3）通过mmap函数映射内存区

参考IO操作说明，几个进程可以映射同一内存区。

#### 4）Socket

目前最广泛使用的IPC（进程间通信）机制，与FIFO一样是利用文件系统中的特殊文件socket来标识内核中的通道。

#### 5）信号

进程之间互发信号，一般使用`SIGUSR1`和`SIGUSR2`实现用户自定义功能。

#### 6）消息队列、信号量和共享内存

以前的SYS V UNIX系统实现的IPC机制，现在已经基本废弃。

### 5.守护进程

守护进程（Daemon）没有控制终端，不需直接和用户交互，不受用户登录注销的影响，一直在后台运行着。

```c
#include <stdio.h>
#include <stdlib.h>
//进程需要使用的头文件
#include <sys/types.h>
#include <unistd.h>

//file操作需要的头文件
#include <sys/stat.h>
#include <fcntl.h>

int main(void)
{
	pid_t pid;
	
	if ((pid = fork()) < 0) {
		perror("fork");
		exit(1);
	}
	
	if (pid > 0) {
		//终结父进程
		exit(0);
	}
	
	//子进程调用setsid创建新的Session，成为守护进程
	setsid();
	
	//按照守护进程的惯例，通常将当前工作目录切换到根目录
	if (chdir("/") < 0) {
		perror("chdir");
		exit(1);
	}
	
	//将标准输入0、标准输出1、标准错误2指向/dev/null
	close(0);
	open("/dev/null", O_RDWR);
	dup2(0, 1);
	dup2(0, 2);
	
	while (1) {
		//执行守护进程的操作
		sleep(1);
		;
	}
	
	return 0;
}
```

