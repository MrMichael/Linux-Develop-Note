### 1.产生信号

1）通过kill函数

- `kill`函数可以给一个指定的进程发送指定的信号。

- `raise`函数可以给当前进程发送指定的信号（自己给自己发信号）

```c
#include <signal.h>

int kill(pid_t pid, int signo);
int raise(int signo);

/*
成功返回0，错误返回-1。
*/
```

2）通过SIGPIPE函数

```c
#include <unistd.h>

unsigned int alarm(unsigned int seconds);
/*
告诉内核在seconds秒之后给当前进程发SIGALRM信号。
*/
```

注意：信号产生函数不能放在信号处理函数中

### 2.阻塞信号

信号从产生到递达之间的状态，称为信号*未决*（Pending）。进程可以选择阻塞（Block）某个信号。被阻塞的信号产生时将保持在未决状态，直到进程解除对此信号的阻塞，才执行递达的动作。

1）信号集操作函数

修改信号集变量

```c
#include <signal.h>

int sigemptyset(sigset_t *set);//初始化set所指向的信号集，使其中所有信号的对应bit清零，表示该信号集不包含任何有效信号。
int sigfillset(sigset_t *set);//初始化set所指向的信号集，使其中所有信号的对应bit置位，表示该信号集的有效信号包括系统支持的所有信号。
int sigaddset(sigset_t *set, int signo);//添加某种有效信号
int sigdelset(sigset_t *set, int signo);//删除某种有效信号
int sigismember(const sigset_t *set, int signo);//判断一个信号集的有效信号中是否包含某种信号，若包含则返回1，不包含则返回0，出错返回-1。

/*
成功返回0，出错返回-1
*/
```

2）修改进程信号屏蔽字

真正开始屏蔽信号

```c
#include <signal.h>

int sigprocmask(int how, const sigset_t *set, sigset_t *oset);//读取或更改进程的信号屏蔽字
/*
how参数：
SIG_BLOCK	set包含了我们希望添加到当前信号屏蔽字的信号，相当于mask=mask|set
SIG_UNBLOCK	set包含了我们希望从当前信号屏蔽字中解除阻塞的信号，相当于mask=mask&~set
SIG_SETMASK	设置当前信号屏蔽字为set所指向的值，相当于mask=set

先将原来的信号屏蔽字备份到oset里，然后根据set和how参数更改信号屏蔽字

若成功则为0，若出错则为-1
*/

```

3）检测当前进程信号集

通过sigismember函数可以判断出当前信号集是否包含未决信号

```c
#include <signal.h>

int sigpending(sigset_t *set);//读取当前进程的未决信号集，通过set参数传出
/*
调用成功则返回0，出错则返回-1。
*/
```

4）实例

设置进程对SIGINT信号挂起

```c
#include <stdio.h>
#include <stdlib.h>
//信号需要的头文件
#include <unistd.h>
#include <signal.h>

int main(void)
{
	int i = 0;
	//定义信号集
	sigset_t s,p;
	
	//定义信号集
	sigemptyset(&s);
	sigaddset(&s, SIGINT); //在信号集中只将SIGINT置位
	//在进程信号屏蔽字中添加SIGINT，即该进程将会使收到的SIGINT信号pending
	sigprocmask(SIG_BLOCK, &s, NULL);
	
	while (1) {
        //读取当前进程的未决信号集
		sigpending(&p);
		
		for (i = 0; i < 32; i++) {
			//如果进程中有被pending的信号
			if (sigismember(&p, i) == 1) {
				printf("signal:%d\n",i);
			}
		}
		sleep(1);
	}
	return 0;
}
```

### 3.捕捉信号

如果信号的处理动作是用户自定义函数，在信号递达时就调用这个函数，这称为捕捉信号。

1）重定义信号处理函数

```c
#include <signal.h>

int sigaction(int signo, const struct sigaction *act, struct sigaction *oact);
```

2）挂起进程等待信号

```c
#include <unistd.h>

int pause(void);
/*
如果信号的处理动作是捕捉，则调用了信号处理函数之后pause返回-1，errno设置为EINTR，所以pause只有出错的返回值
*/
```

3）解除信号屏蔽并挂起等待信号

```c
#include <signal.h>

int sigsuspend(const sigset_t *sigmask);
/*
进程的信号屏蔽字由sigmask参数指定，可以通过指定sigmask来临时解除对某个信号的屏蔽，然后挂起等待，当sigsuspend返回时，进程的信号屏蔽字恢复为原来的值。

sigsuspend没有成功返回值，只有执行了一个信号处理函数之后sigsuspend才返回，返回值为-1，errno设置为EINTR。
*/
```

4）实例1 

使用pause挂起等待

```c
#include <stdio.h>
#include <stdlib.h>
//signal需要的头文件
#include <unistd.h>
#include <signal.h>

//改变SIGALRM信号的处理函数
//alarm 触发SIGALRM信号，执行sigalrm_handler函数

void sigalrm_handler(int sig)
{
	printf("Get a signal %d\n", sig);
}

int main(void)
{
	struct sigaction actnew, actold;
	
	//重新定义信号处理函数
	actnew.sa_handler = sigalrm_handler;
	actnew.sa_flags = 0;
	sigemptyset(&actnew.sa_mask); //信号处理函数执行期间 不屏蔽信号
	sigaction(SIGALRM, &actnew, &actold); //actold保存原来的处理动作
	
	while (1) {
		alarm(2);
		//bug：如果在alarm与pause之间出现更高级的中断或进程任务，在SIGALRM信号出现后还没恢复，则会导致pluse函数一直挂起程序
		
		//使进程挂起直到有信号抵达
		//信号抵达后先执行信号处理函数，再往下执行
		pause();
		printf("have a signal\n");
	}
	
	return 0;
}
```

5）实例2

使用sigsuspend挂起等待

```c
#include <stdio.h>
#include <stdlib.h>
//signal需要的头文件
#include <unistd.h>
#include <signal.h>

//改变SIGALRM信号的处理函数
//alarm 触发SIGALRM信号，执行sigalrm_handler函数
//sigsuspend保证进程一定可以监听到SIGALRM信号

void signal_handler(int sig)
{
	printf("get a signal %d\n", sig);
}

int main(void)
{
	struct sigaction act_new, act_old;
	sigset_t mask_new, mask_old;
	
	//重新定义信号处理函数
	act_new.sa_handler = signal_handler;
	act_new.sa_flags = 0;
	sigemptyset(&act_new.sa_mask);
	sigaction(SIGALRM, &act_new, &act_old);
	
	//进程先屏蔽SIGALRM信号
	sigemptyset(&mask_new);
	sigaddset(&mask_new, SIGALRM);
	sigprocmask(SIG_BLOCK, &mask_new, &mask_old);
	
	while (1) {
		alarm(2);
		
		//临时设置新的信号屏蔽(打开SIGALRM信号)，并挂起进程
		//直到有信号抵达恢复原来的信号屏蔽并往下执行
		sigsuspend(&mask_old);//将挂起pluse()函数和sigprocmask函数合并
		printf("have a signal\n");
	}
	
	return 0;
}
```

### 4.通过SIGCHLD信号处理子进程终结

- `wait`和`waitpid`函数清理僵尸进程，父进程需要阻塞等待子进程结束。

- 子进程在终止时会给父进程发`SIGCHLD`信号，该信号的默认处理动作是忽略，父进程可以自定义`SIGCHLD`信号的处理函数，当子进程终止时会通知父进程，父进程在信号处理函数中调用`wait`清理子进程即可。

```c
#include <stdio.h>
#include <stdlib.h>
//signal需要使用的头文件
#include <unistd.h>
#include <signal.h>
//进程需要使用的头文件
#include <sys/types.h>
//#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

//子进程终止时都会给父进程发送SIGCHLD信号
//重定义SIGCHLD信号处理函数，自动调用wait清理子进程，父进程不必阻塞

void signal_handler(int sig)
{
	printf("child exit\n");
	wait(NULL); //回收资源
}

int main(void)
{
	pid_t pid;
	
	if ((pid = fork()) < 0) {
		perror("fork");
		exit(1);
	}
		
	if (pid == 0) {
		//child
		sleep(1);
		printf("I am child\n");
		exit(2);
	} else {
		//parent
		struct sigaction act_new;
		
        //重新定义SIGCHLD信号处理函数
		act_new.sa_handler = signal_handler;
		act_new.sa_flags = 0;
		sigemptyset(&act_new.sa_mask);
		sigaction(SIGCHLD, &act_new, NULL);
		
		while (1) {
			printf("I am parent\n");
			sleep(1);
		}
		
	}
	return 0;
}
```

