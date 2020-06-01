
### 1.open与close

```c
#include <stdio.h>
//IO操作需要包含的头文件
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

char filename[] = "text.txt";

int main(void)
{
	int fd;

	fd = open(filename, O_RDWR | O_CREAT, 0777);
	if (fd != -1) {
		printf("open %s ok\r\n",filename);
		if (close(fd) != -1) {
			printf("close %s ok\r\n",filename);
			
		} else {
			printf("close %s fail\r\n",filename);
		}
	} else {
		printf("open %s fail\r\n",filename);
	}

	return 0;
}
```

**常用flags有:**

以下三个常数中必须指定一个，且仅允许指定一个。

- `O_RDONLY` 只读打开
- `O_WRONLY` 只写打开
- `O_RDWR` 可读可写打开

以下可选项可以同时指定0个或多个，和必选项按位或起来作为`flags`参数。可选项有很多，这里只介绍一部分，其它选项可参考`open(2)`的Man Page：

- `O_APPEND` 表示追加。如果文件已有内容，这次打开文件所写的数据附加到文件的末尾而不覆盖原来的内容。
- `O_CREAT` 若此文件不存在则创建它。使用此选项时需要提供第三个参数`mode`，表示该文件的访问权限。
- `O_EXCL` 如果同时指定了`O_CREAT`，并且文件已存在，则出错返回。
- `O_TRUNC` 如果文件已存在，并且以只写或可读可写方式打开，则将其长度截断（Truncate）为0字节。
- `O_NONBLOCK` 对于设备文件，以`O_NONBLOCK`方式打开可以做非阻塞I/O（Nonblock I/O）

### 2.read与write

```c
#include <stdio.h>
#include <stdlib.h>
//IO操作需要包含的头文件
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

char filename[] = "./text.txt";

int main(void)
{
	int fd;
	char buf[10];
	int n;
	int i = 0;
	int len;
	
	//如果文件不存在就创建文件
	fd = open(filename, O_RDWR | O_CREAT, 0777);
	//fd = open(filename, O_RDONLY | O_WRONLY);
	if(fd == -1) {
		printf("open %s fail\r\n",filename);
		exit(1);
	} else {
		printf("open %s ok\r\n", filename);
	}
	
	n = write(fd, "1234567890", 10);
	if(n == -1) {
		printf("write %s fail\r\n",filename);
	} else {
		printf("write %s %d buff\r\n",filename, n);
	}
	
	//由于write操作会使读写位置处于内容末尾，需要指向到当前位置的前10偏移位置
	lseek(fd, -10, SEEK_CUR);
	
	n = read(fd, buf, 10);
	if(n == -1) {
		printf("read %s fail\r\n",filename);
	} else {
		printf("read %s %d buff\r\n",filename, n);
	}

	printf("read buf len:%d\r\n", n);
	//write(STDOUT_FILENO, buf, 10);
	for (i = 0; i < 10; i++)
	{
		printf("%c",buf[i]);
	}
	
	if(close(fd) == -1) {
		printf("close %s fail\r\n",filename);
		exit(1);
	} else {
		printf("close %s ok\r\n", filename);
	}

	return 0;
}
```

### 3.mmap

`mmap`可以把磁盘文件的一部分直接映射到内存，这样文件中的位置直接就有对应的内存地址，对文件的读写可以直接用指针来做而不需要`read`/`write`函数。

![image](http://upload-images.jianshu.io/upload_images/15877540-23c4e65c995632b4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```c
#include <stdio.h>
#include <stdlib.h>
//内存映射需要的头文件
#include <sys/mman.h>
//文件操作需要的头文件
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int main(void)
{
	int *p;
	int fd;
    
    //判断文件是否存在
    if (access("text.txt",F_OK) == -1) {
        perror("access text.txt");
		exit(1);
    }

	fd	= open("text.txt", O_RDWR);
	if (fd == -1) {
		perror("open text.txt");
		exit(1);
	}
	
	//映射之前文件内容不能为空，否则映射出错
	//mmap没法增加文件长度，通过内存对文件操作的数据长度不会超过文件本身包含的数据长度的
	//length==6，代表将文件中6word的数据映射到内存，但如果length小于一个内存页的长度，
	//测试发现实际设置共享内存的大小是一页。
	p = mmap(NULL, 6, PROT_WRITE, MAP_SHARED, fd, 0);
	if (p == MAP_FAILED) {
		perror("mmap");
		exit(1);
	}
	
	if (close(fd) == -1)
	{
		perror("close text.txt");
		exit(1);
	}
	
	p[0] = 0x31303030;	//低位在前，高位在后 X86架构下
	p[1] = 0x32303030;
	p[2] = 0x33303030;
	p[3] = 0x34303030;
	p[4] = 0x35303030;
	p[5] = 0x36303030;

    //取消映射
	if (munmap(p, 6) == -1) {
		perror("munmap");
		exit(1);
	}
	
	return 0;
}
```

`prot`参数有四种取值：

- PROT_EXEC表示映射的这一段可执行，例如映射共享库
- PROT_READ表示映射的这一段可读
- PROT_WRITE表示映射的这一段可写
- PROT_NONE表示映射的这一段不可访问

flag`参数有很多种取值，这里只讲两种，其它取值可查看`mmap(2)

- MAP_SHARED多个进程对同一个文件的映射是共享的，一个进程对映射的内存做了修改，另一个进程也会看到这种变化。
- MAP_PRIVATE多个进程对同一个文件的映射不是共享的，一个进程对映射的内存做了修改，另一个进程并不会看到这种变化，也不会真的写到文件中去。

### 4.实用工具

**1）access**

用于判断该文件是否存在或者是否可以读/写某一已存在的文件。

```c
#include<unistd.h>
int access(const char * pathname,int mode);
/*
pathname：文件路径
mode： 文件访问的权限
R_OK，W_OK与X_OK：检查文件是否具有读取、写入和执行的权限。
F_OK：判断该文件是否存在。

返回0值，表示成功，只要有一权限被禁止则返回-1。
*/
```

**2）lseek**

改变文件当前读写位置。打开文件时读写位置是0，表示文件开头，通常读写多少个字节就会将读写位置往后移多少个字节。

```c
#include <sys/types.h>
#include <unistd.h>

off_t lseek(int fd, off_t offset, int whence);

/*
fd 表示要操作的文件描述符
offset是相对于whence（基准）的偏移量
whence 可以是SEEK_SET（文件指针开始），SEEK_CUR（文件指针当前位置） ，SEEK_END为文件指针尾

返回值：文件读写指针距文件开头的字节大小，出错，返回-1
*/
```

