各线程共享的进程资源和环境

- 进程同一地址空间
- 同一进程定义的函数和全局变量
- 文件描述符表
- 每种信号的处理方式（`SIG_IGN`、`SIG_DFL`或者自定义的信号处理函数）
- 当前工作目录
- 用户id和组id

线程各自独立的资源

- 线程id
- 上下文，包括各种寄存器的值、程序计数器和栈指针
- 栈空间
- `errno`变量
- 信号屏蔽字
- 调度优先级



### 1.创建线程

```c
#include <stdio.h>
#include <stdlib.h>
//线程所需要的头文件
#include <pthread.h>
//getpid需要的头文件
#include <unistd.h>

//线程编译需要加上-lpthread

int temp = 0;

void printids(char *s)
{
	pid_t pid;
	pthread_t tid;
	
	pid = getpid();
	tid = pthread_self();//获取当前线程id
	//由于pthread_t并不是一个整型，所以需要做强制类型转换
	printf("%s pid:%d, tid:%u\n", s, pid, (unsigned int)tid);
	
}

//线程处理函数
void  *thread_handler(void *arg)
{
	static int value = 0;
	
	temp++;	//线程间共享全局变量、局部变量、函数
	value++;
	printf("%s value:%d, temp:%d\n", (char*)arg, value, temp);
	
	printids(arg);
	return NULL;
}

int main(void)
{
	pthread_t tid;
	int err;
	
	/*
	 * 返回线程id
	 * 线程属性设置
	 * 线程处理函数
	 * 线程处理函数参数
	 */
	err = pthread_create(&tid, NULL, thread_handler, "new_thread1");
	//pthread_create失败返回错误码
	if (err != 0) {
		//由于pthread_create的错误码不保存在errno中，因此不能直接用perror()打印错误信息
		fprintf(stderr, "pthread_create1\n");
		exit(1);
	}
	printf("create tid %u\n", (unsigned int)tid);
	
	err = pthread_create(&tid, NULL, thread_handler, "new_thread2");
	//pthread_create失败返回错误码
	if (err != 0) {
		//由于pthread_create的错误码不保存在errno中，因此不能直接用perror()打印错误信息
		fprintf(stderr, "pthread_create2\n");
		exit(1);
	}
	printf("create tid %u\n", (unsigned int)tid);
	
	printids("main_thread");
	sleep(2);//预留线程调度的时间
	return 0;
}
```

### 2.终止线程

只终止某个线程可以有三种方法：

- 从线程函数`return`。这种方法对主线程不适用，从`main`函数`return`相当于调用`exit`。
- 一个线程可以调用`pthread_cancel`终止同一进程中的另一个线程。
- 线程可以调用`pthread_exit`终止自己。

1）终止某个线程

```c
#include <pthread.h>

void pthread_exit(void *value_ptr);
/*
成功返回0，失败返回错误号
*/
```

2）自身线程挂起等待某线程终止

```c
#include <pthread.h>

int pthread_join(pthread_t thread, void **value_ptr);
/*
成功返回0，失败返回错误号
*/
```

3）实例

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
//线程所需头文件
#include <pthread.h>

void *thread1_handler(void *arg)
{
	printf("%s running\n", (char*)arg);
	return (void *)1;	//return 终止线程返回return值
}

void *thread2_handler(void *arg)
{
	printf("%s running\n", (char*)arg);
	pthread_exit((void *)2); //pthread_exit终止线程返回其参数值
}

void *thread3_handler(void *arg)
{
	while (1) {
		printf("%s waiting\n", (char*)arg);
		sleep(1);
	}
	//线程被异常终止，返回常数PTHREAD_CANCELED，即-1。
}

int main(void)
{
	pthread_t tid1, tid2, tid3;
	void *ptr;
	int err;
	
	//thread 1
	err = pthread_create(&tid1, NULL, thread1_handler, "new thread1");
	if (err != 0) {
		fprintf(stderr, "pthread_create1\n");
		exit(1);
	}
	
	//阻塞等待thread 1终止  （主进程同时也是一个线程）
	err = pthread_join(tid1, &ptr);
	if (err != 0) {
		fprintf(stderr, "pthread_join\n");
		exit(1);
	}
	printf("thread1 exit code %d\n", (int)ptr);
	
	//thread 2
	err = pthread_create(&tid2, NULL, thread2_handler, "new thread2");
	if (err != 0) {
		fprintf(stderr, "pthread_create2\n");
		exit(1);
	}
	
	//阻塞等待thread 2终止
	err = pthread_join(tid2, &ptr);
	if (err != 0) {
		fprintf(stderr, "pthread_join\n");
		exit(1);
	}
	printf("thread2 exit code %d\n", (int)ptr);
	
	//thread 3
	err = pthread_create(&tid3, NULL, thread3_handler, "new thread3");
	if (err != 0) {
		fprintf(stderr, "pthread_create3\n");
		exit(1);
	}
	
	sleep(3);
	//主线程将thread 3异常终止
	pthread_cancel(tid3);
	//阻塞等待thread 3终止
	err = pthread_join(tid3, &ptr);
	if (err != 0) {
		fprintf(stderr, "pthread_join\n");
		exit(1);
	}
	printf("thread3 exit code %d\n", (int)ptr);
	
	return 0;
}
```

### 3.线程间同步

多个线程同时访问共享数据时可能会冲突，使用互斥量mutex或可以解决冲突问题。

#### 1）互斥量mutex

Mutex变量是非0即1的，可看作一种资源的可用数量，初始化时Mutex是1，表示有一个可用资源，加锁时获得该资源，将Mutex减到0，表示不再有可用资源，解锁时释放该资源，将Mutex重新加到1，表示又有了一个可用资源。

```c
#include <pthread.h>

int pthread_mutex_init(pthread_mutex_t *restrict mutex,const pthread_mutexattr_t *restrict attr);//动态初始化互斥量
int pthread_mutex_destroy(pthread_mutex_t *mutex);//销毁互斥量
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;//静态初始化互斥量
```

实例

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
//线程所需头文件
#include <pthread.h>

#define NLOOP	5000
int counter = 0;

//静态初始化互斥量（静态初始化要比动态初始化好）
pthread_mutex_t	counter_mutex = PTHREAD_MUTEX_INITIALIZER;

void *add(void *arg)
{
	int i = 0;
	int val = 0;
	
	for (i = 0; i < NLOOP; i++) {
		//阻塞获取互斥量
		pthread_mutex_lock(&counter_mutex);
		
		val = counter;
		//printf调用，它会执行write系统调用进内核，为内核调度别的线程执行提供了一个很好的时机
		printf("%s %x: val:%d\n", (char *)arg, (unsigned int)pthread_self(), val);
		counter++;
		
		//解除互斥量
		pthread_mutex_unlock(&counter_mutex);
		
	}
	return NULL;
}

int main(void)
{
	pthread_t tid1, tid2;
	int err;
	
	err = pthread_create(&tid1, NULL, add,"thread1");
	if (err != 0) {
		fprintf(stderr, "pthread_create\n");
		exit(1);
	}
	
	err = pthread_create(&tid2, NULL, add,"thread2");
	if (err != 0) {
		fprintf(stderr, "pthread_create\n");
		exit(1);
	}
	
	pthread_join(tid1, NULL);
	pthread_join(tid1, NULL);
	
	printf("\nEND counter:%d\n",counter);
}
```

#### 2）条件变量condition

如果两个线程在等待对方的资源，就会出现死锁现象。

通过条件变量（Condition Variable）来阻塞等待一个条件，或者唤醒等待这个条件的线程。

```c
#include <pthread.h>

int pthread_cond_init(pthread_cond_t *restrict cond,const pthread_condattr_t *restrict attr);//动态初始化一个条件变量
int pthread_cond_destroy(pthread_cond_t *cond);//销毁一个条件变量
pthread_cond_t cond = PTHREAD_COND_INITIALIZER;//静态初始化一个条件变量
/*
成功返回0，失败返回错误号
*/
```

实例

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
//线程所需头文件
#include <pthread.h>

//程序演示一个生产者-消费者的例子，生产者生产一个结构体串在链表的表头上，消费者从表头取走结构体。

//定义链表
struct msg {
	struct msg *next;
	int value;
};

struct msg *head;

//静态初始化互斥量
pthread_mutex_t product_mutex = PTHREAD_MUTEX_INITIALIZER;

//静态初始化条件变量
pthread_cond_t	product_cond = PTHREAD_COND_INITIALIZER;	

void *consumer(void *arg)
{
	struct msg *mp;
	
	while (1) {
		//阻塞获取互斥量
		pthread_mutex_lock(&product_mutex);
		while (head == NULL) {
			//释放互斥量并阻塞线程，直到被唤醒时重新获取互斥量
			pthread_cond_wait(&product_cond, &product_mutex);
		}
		//修改全局变量
		mp = head;
		head = mp->next;
		//释放互斥量
		pthread_mutex_unlock(&product_mutex);
		
		printf("Consume %d\n", mp->value);
		//释放内存空间
		free(mp);
		sleep(rand() % 5);
	}
	return NULL;
}

void *producer(void *arg)
{
	struct msg *mp;
	
	while (1) {
		//申请内存空间
		mp = malloc(sizeof(struct msg));
		mp->value = rand() % 1000 + 1;
		printf("Produce %d\n", mp->value);
		
		//阻塞获取互斥量
		pthread_mutex_lock(&product_mutex);
		//修改全局变量
		mp->next = head;
		head = mp;
		//释放互斥量
		pthread_mutex_unlock(&product_mutex);
		
		//唤醒一个在等待条件变量的线程
		pthread_cond_signal(&product_cond);
		sleep(rand() % 5);
	}
	
	return NULL;
}

int main(void)
{
	pthread_t tid_p, tid_c;
	int err;
	
	//设置随机数种子
	srand(time(NULL));
	
	err = pthread_create(&tid_p, NULL, producer, "thread producer");
	if (err != 0) {
		fprintf(stderr, "pthread_create\n");
		exit(1);
	}
	
	err = pthread_create(&tid_p, NULL, consumer, "thread consumer");
	if (err != 0) {
		fprintf(stderr, "pthread_create\n");
		exit(1);
	}
	
	pthread_join(tid_p, NULL);
	pthread_join(tid_c, NULL);
	
	return 0;
}
```

#### 3）信号量Semaphore

信号量（Semaphore）和Mutex类似，表示可用资源的数量，和Mutex不同的是这个数量可以大于1。

```c
#include <semaphore.h>

int sem_init(sem_t *sem, int pshared, unsigned int value);//初始化一个semaphore变量，value参数表示可用资源的数量，pshared参数为0表示信号量用于同一进程的线程间同步
int sem_wait(sem_t *sem);//获得资源，使semaphore的值减1，如果semaphore的值已经是0，则挂起等待
int sem_trywait(sem_t *sem);//获得资源，使semaphore的值减1，如果semaphore的值已经是0，不会挂起等待
int sem_post(sem_t * sem);//释放资源，使semaphore的值加1，同时唤醒挂起等待的线程。
int sem_destroy(sem_t * sem);//销毁信号量
```

实例

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
//线程所需头文件
#include <pthread.h>
//信号量所需头文件
#include <semaphore.h>

//生产者－消费者的例子是基于链表的，其空间可以动态分配，
//现在基于固定大小的环形队列重写这个程序

#define NUM		5
int queue[NUM];
sem_t blank_number, product_number;

void *producer(void *arg)
{
	int  p = 0;
	
	while (1) {
		//等待信号量
		sem_wait(&blank_number);
		queue[p] = rand() % 1000 + 1;
		printf("Produce %d\n", queue[p]);
		//释放信号量
		sem_post(&product_number);
		p = (p+1)%NUM;
		sleep(rand()%5);
	}
}

void *consumer(void *arg)
{
	int c = 0;
	
	while(1) {
		sem_wait(&product_number);
		printf("Comsume %d\n", queue[c]);
		queue[c] = 0;
		sem_post(&blank_number);
		c = (c+1)%NUM;
		sleep(rand()%5);
	}
}

int main(void)
{
	pthread_t tid1, tid2;
	int err;
	
	//初始化信号量,0代表信号量用于线程间同步，NUM代表信号量可用资源数量
	sem_init(&blank_number, 0, NUM);
	sem_init(&product_number, 0, 0);
	//创建线程
	err = pthread_create(&tid1, NULL, producer, NULL);
	if (err != 0) {
		fprintf(stderr, "pthread_create\n");
		exit(1);
	}
	err = pthread_create(&tid2, NULL, consumer, NULL);
	if (err != 0) {
		fprintf(stderr, "pthread_create\n");
		exit(1);
	}
	//等待线程退出
	pthread_join(tid1, NULL);
	pthread_join(tid2, NULL);
	
	//销毁信号量
	sem_destroy(&blank_number);
	sem_destroy(&product_number);
	
	return 0;
}
```

