
### 1.基本规则

```makefile
#规则格式
target ... : prerequisites ... 
	command1
	command2
	
#例如
main: main.o stack.o maze.o
	gcc main.o stack.o maze.o -o main
```

- `main`是规则的目标（Target），`main.o`、`stack.o`和`maze.o`是规则的条件（Prerequisite），command是规则的命令列表。
- 目标和条件之间的关系是：`欲更新目标，必须首先更新它的所有条件；所有条件中只要有一个条件被更新了，目标也必须随之被更新。`
- 如果一个目标拆开写多条规则，则只有一条规则允许有命令列表，其它规则不能有命令列表，否则`make`会报警告并且采用最后一条规则的命令列表。
- “更新”就是执行一遍规则中的命令列表（commands），命令列表中的每条命令必须以一个Tab开头。

**make执行步骤**

1. 尝试更新Makefile中第一条规则的目标`main`，第一条规则的目标称为缺省目标，只要缺省目标更新了就算完成任务了，其它工作都是为这个目的而做的。由于是第一次编译，`main`文件还没生成，显然需要更新，但规则说必须先更新了`main.o`、`stack.o`和`maze.o`这三个条件，然后才能更新`main`。

2. 所以`make`会进一步查找以这三个条件为目标的规则，这些目标文件也没有生成，也需要更新，所以执行相应的命令（`gcc -c main.c`、`gcc -c stack.c`和`gcc -c maze.c`，通过隐含规则）更新它们。

3. 最后执行`gcc main.o stack.o maze.o -o main`更新`main`。

   ![Makefile的依赖关系图](http://upload-images.jianshu.io/upload_images/15877540-2fe7e26e4f6b00d4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 2.隐含规则与模式规则

- 如果一个目标在Makefile中的所有规则都没有命令列表，`make`会尝试在内建的隐含规则（Implicit Rule）数据库中查找适用的规则。

- `make`的隐含规则数据库可以用`make -p`命令打印，也是Makefile的格式，包括很多变量和规则。如：

  ```makefile
  #通过.c文件编译出.o文件的默认规则
  
  # default
  OUTPUT_OPTION = -o $@
  
  # default
  CC = cc
  
  # default
  COMPILE.c = $(CC) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
  
  %.o: %.c
  #  commands to execute (built-in):
          $(COMPILE.c) $(OUTPUT_OPTION) $<
  ```

  `$@`的取值为规则中的目标，`$<`的取值为规则中的第一个条件。

  `%.o: %.c`是一种特殊的规则，称为模式规则（Pattern Rule）。

### 3.伪目标

伪目标是一个标签，这个目标只执行命令，不创建目标，能避免目标与工作目录下的实际文件名冲突。

```makefile
PHONY:标签
```

例如将 all 设置为伪目标后，尽管在当前目录下有同名的 all 文件，但是在终端输入 make 命令， all 的命令会被正确执行。

### 4.变量

```makefile
foo = $(bar) 
bar = Huh? 

all: 
	@echo $(foo)

#在调用变量是才会把变量$(bar) 展开
```

**1）自动变量（隐含规则变量）**

| 自动变量 | 含义                                                         |
| -------- | ------------------------------------------------------------ |
| $@       | 规则的目标文件名                                             |
| $<       | 规则的目标的第一个依赖文件名                                 |
| $^       | 规则的目标所对应的所有依赖文件的列表，以空格分隔             |
| $?       | 规则的目标所对应的依赖文件新于目标文件的文件列表，以空格分隔 |
| $(@D)    | 规则的目标文件的目录部分（如果目标在子目录中）               |
| $(@F)    | 规则的目标文件的文件名部分（如果目标在子目录中）             |

**2）预定义变量（隐含规则变量）**

| 预定义变量 | 含义                                                         |
| ---------- | ------------------------------------------------------------ |
| AR         | 归档维护程序，默认值为 ar                                    |
| AS         | 汇编程序，默认值为 as                                        |
| CC         | C 语言编译程序，默认值为 cc                                  |
| CPP        | C 语言预处理程序，默认值为 cpp                               |
| RM         | 文件删除程序，默认值为 rm -f                                 |
| ARFLAGS    | 传递给 AR 程序的标志，默认为 rv                              |
| ASFLAGS    | 传递给 AS 程序的标志，默认值无                               |
| CFLAGS     | 传递给 CC 程序的标志，默认值无。编译选项，例如`-O`、`-g`等   |
| CPPFLAGS   | 传递给 CPP 程序的标志，默认值无。预处理选项，例如`-D`、`-I`等 |
| LDFLAGS    | 传递给链接程序的标志，默认值无                               |

### 5.常用make命令行选项

**1）-C**

- `-C`选项可以切换到另一个目录执行那个目录下的Makefile。

- 一些规模较大的项目会把不同的模块或子系统的源代码放在不同的子目录中，然后在每个子目录下都写一个该目录的Makefile，然后在一个总的Makefile中用`make -C`命令执行每个子目录下的Makefile。如Linux内核源代码。

```makefile
ARCH ?=
CROSS_COMPILE ?= mipsel-openwrt-linux-gnu-
export

### general build targets

all:
	$(MAKE) all -e -C libloragw
	$(MAKE) all -e -C util_pkt_logger
	$(MAKE) all -e -C util_spi_stress
	$(MAKE) all -e -C util_tx_test
	$(MAKE) all -e -C util_lbt_test
	$(MAKE) all -e -C util_tx_continuous
	$(MAKE) all -e -C util_spectral_scan

clean:
	$(MAKE) clean -e -C libloragw
	$(MAKE) clean -e -C util_pkt_logger
	$(MAKE) clean -e -C util_spi_stress
	$(MAKE) clean -e -C util_tx_test
	$(MAKE) clean -e -C util_lbt_test
	$(MAKE) clean -e -C util_tx_continuous
	$(MAKE) clean -e -C util_spectral_scan

### EOF
```

### 6.实例

文件目录

```shell
$ tree
.
├── makefile
├── testadd
│   ├── add.c
│   └── add.h
├── test.c
├── test.h
└── testsub
    ├── sub.c
    └── sub.h
```

Makefile文件

```makefile
# 预定义变量 指令编译器和选项
CC = gcc			#C 语言编译程序
CFLAGS = -Wall -g	#传递给 CC 程序的标志
LDFLAGS = -L -lFOO	#传递给链接程序的标志 库文件链接

# 自定义变量，目标文件, 变量引用为$(变量)
TARGET = test			
SRC = test.c \
	./testadd/add.c \
	./testsub/sub.c

#头文件路径
INC = -I ./ -I ./testadd -I ./testsub


# makefile规则，第一个目标文件为make默认的执行目标
all:test.c ./testadd/add.c ./testsub/sub.c
	gcc -I ./ -I ./testadd -I ./testsub -o test test.c ./testadd/add.c ./testsub/sub.c
	
exe1:$(SRC)			#输入make exe1执行特定的目标规则
	$(CC) $(LDFLAGS) $(INC) -o $(TARGET) $(SRC)
	
$(TARGET):$(SRC)
	$(CC) $(LDFLAGS) $(INC) -o $@ $^		# $@目标文件，$^包含所有的依赖文件

.PHONY:clean		#将目标文件clean设置为伪目标，该目标的规则被执行后不产生文件
clean:				#makefile规则
	rm -f $(TARGET) *.o	#*.o是指任意.o文件
```


