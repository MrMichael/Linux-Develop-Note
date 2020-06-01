[TOC]



### 一、简介

**Go**（又称**Golang**）是[Google](https://zh.wikipedia.org/wiki/Google)开发的一种[静态](https://zh.wikipedia.org/wiki/静态类型)[强类型](https://zh.wikipedia.org/wiki/強類型)、[编译型](https://zh.wikipedia.org/wiki/編譯語言)、[并发型](https://zh.wikipedia.org/wiki/並行計算)，并具有[垃圾回收功能](https://zh.wikipedia.org/wiki/垃圾回收_(計算機科學))的[编程语言](https://zh.wikipedia.org/wiki/编程语言)。Go于2009年11月正式宣布推出，成为[开放源代码](https://zh.wikipedia.org/wiki/開放原始碼)项目，支持[Linux](https://zh.wikipedia.org/wiki/Linux)、[macOS](https://zh.wikipedia.org/wiki/MacOS)、[Windows](https://zh.wikipedia.org/wiki/Windows)等操作系统。



#### 1.Go 语言的目标与意义

- Go 语言的主要目标是将静态语言的安全性和高效性与动态语言的易开发性进行有机结合，达到完美平衡。
  - Go 语言是一门类型安全和内存安全的编程语言。虽然 Go 语言中仍有指针的存在，但并不允许进行指针运算。

- Go 语言的另一个目标是对于网络通信、并发和并行编程的极佳支持，从而更好地利用大量的分布式和多核的计算机。
  - 通过 goroutine 这种轻量级线程的概念来实现这个目标，然后通过 channel 来实现各个 goroutine 之间的通信。

- Go 语言的构建速度（编译和链接到机器代码的速度），一般情况下构建一个程序的时间只需要数百毫秒到几秒。

- Go 语言不需要开发人员需要考虑内存问题（内存泄漏）
  - Go 语言像其它静态语言一样执行本地代码，但它依旧运行在某种意义上的虚拟机，以此来实现高效快速的垃圾回收（使用了一个简单的标记-清除算法）。
- Go 语言支持调用由 C 语言编写的海量库文件，从而能够将过去开发的软件进行快速迁移。



#### 2.与其他语言的比较

- Go的语法接近[C语言](https://zh.wikipedia.org/wiki/C语言)，但对于[变量的声明](https://zh.wikipedia.org/w/index.php?title=变量的声明&action=edit&redlink=1)有所不同。Go支持[垃圾回收功能](https://zh.wikipedia.org/wiki/垃圾回收_(計算機科學))。Go的[并行计算](https://zh.wikipedia.org/wiki/并行计算)模型是以[通信顺序进程](https://zh.wikipedia.org/wiki/交談循序程式)（CSP）为基础，采取类似模型的其他语言包括[Occam](https://zh.wikipedia.org/wiki/Occam)和[Limbo](https://zh.wikipedia.org/wiki/Limbo)，[[2\]](https://zh.wikipedia.org/wiki/Go#cite_note-langfaq-2)，但它也具有pipeline模型的特征，比如通道传输。在1.8版本中开放插件（Plugin）的支持，这意味着现在能从Go中动态加载部分函数。

- 与C++相比，Go并不包括如[枚举](https://zh.wikipedia.org/wiki/枚举)、[异常处理](https://zh.wikipedia.org/wiki/异常处理)、[继承](https://zh.wikipedia.org/wiki/繼承_(計算機科學))、[泛型](https://zh.wikipedia.org/wiki/泛型)、[断言](https://zh.wikipedia.org/wiki/斷言_(程式))、[虚函数](https://zh.wikipedia.org/wiki/虚函数)等功能，但增加了 切片(Slice) 型、并发、管道、[垃圾回收功能](https://zh.wikipedia.org/wiki/垃圾回收_(計算機科學))、[接口](https://zh.wikipedia.org/wiki/介面_(資訊科技))等特性的语言级支持。

- 不同于[Java](https://zh.wikipedia.org/wiki/Java)，Go原生提供了[关联数组](https://zh.wikipedia.org/wiki/关联数组)（也称为[哈希表](https://zh.wikipedia.org/wiki/哈希表)（Hashes）或字典（Dictionaries）），就像字符串类型一样。



#### 3.Go的缺失特性

- 为了简化设计，不支持函数重载和操作符重载
- 为了避免在 C/C++ 开发中的一些 Bug 和混乱，不支持隐式转换
- Go 语言通过另一种途径实现面向对象设计来放弃类和类型的继承
- 尽管在接口的使用方面可以实现类似变体类型的功能，但本身不支持变体类型
- 不支持动态加载代码
- 不支持动态链接库
- 不支持泛型
- 通过 `recover` 和 `panic` 来替代异常机制（第 13.2-3 节）
- 不支持静态变量





### 二、Go项目风格

#### 1.撰写风格

[Go 语言编码规范](http://golang.org/doc/go_spec.html)

- 每行程序结束后不需要撰写分号（;）。
- 大括号（{）不能够换行放置。
  - 换行会产生编译错误
- if判断式和for循环不需要以小括号包覆起来。
- 使用 tab 做排版

> 备注：除了第二点外，在不符合上述规定时，仍旧可以编译，但使用了内置gofmt工具后，会自动整理代码，使之符合规定的撰写风格。



#### 2.项目架构

- 所有Go项目代码都应该保存在一个工作区中；

- 工作区包含许多版本控制存储库 ；
- 每个存储库包含一个或多个软件包；
- 每个软件包都在一个目录中包含一个或多个Go源文件。



##### 1）Go的工作区的目录结构

$GOPATH路径下

| 目录 |                             用途                             |
| :--: | :----------------------------------------------------------: |
| src  |                           Go源代码                           |
| pkg  | [编译](https://zh.wikipedia.org/wiki/编译)时，生成的[对象文件](https://zh.wikipedia.org/w/index.php?title=對象文件&action=edit&redlink=1) |
| bin  |                         编译后的程序                         |

> **注意** 当创建目录时，文件夹名称永远不应该包含空格，而应该使用下划线 "_" 或者其它一般符号代替。

**项目目录示例**

```shell
bin/
    hello                          # 生成的執行檔
    outyet                         # 生成的執行檔
pkg/
    linux_amd64/
        github.com/golang/example/
            stringutil.a           # 編譯時，生成的對象檔案
src/
    github.com/golang/example/
        .git/                      # 外部 Git 庫的詮釋資料
	hello/
	    hello.go               # Git 庫的程式碼
	outyet/
	    main.go                # Git 庫的程式碼
	    main_test.go           # Git 庫的程式碼（測試用的程式）
	stringutil/
	    reverse.go             # Git 庫的程式碼
	    reverse_test.go        # Git 庫的程式碼（測試用的程式）
    golang.org/x/image/
        .git/                      # 外部 Git 庫的詮釋資料
	bmp/
	    reader.go              # Git 庫的程式碼
	    writer.go              # Git 庫的程式碼
```



##### 2）编译器

当前有两个Go[编译器](https://zh.wikipedia.org/wiki/编译器)分支，分别为官方编译器gc和[gccgo](https://zh.wikipedia.org/w/index.php?title=Gccgo&action=edit&redlink=1)。

- 官方编译器在初期使用C写成，后用Go重写从而实现[自举](https://zh.wikipedia.org/w/index.php?title=自举&action=edit&redlink=1)。

  - 官方编译器支持跨平台编译（但不支持CGO），允许将源代码编译为可在目标系统、架构上执行的二进制文件。

  - 编译器目前支持以下基于 Intel 或 AMD 处理器架构的程序构建。

    ![](https://upload-images.jianshu.io/upload_images/15877540-793131359f95eca6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    ```go
    g = 编译器：将源代码编译为项目代码（程序文本）
    l = 链接器：将项目代码链接到可执行的二进制文件（机器代码）
    ```

    - 相关的 C 编译器名称为 6c、8c 和 5c，相关的汇编器名称为 6a、8a 和 5a

- Gccgo是一个使用标准GCC作为后端的Go编译器。

  - 能够构建基于众多处理器架构的应用程序。编译速度相对 gc 较慢，但产生的本地代码运行要稍微快一点。它同时也提供一些与 C 语言之间的互操作性。



##### 3）文件扩展名与包（package）

- Go 语言源文件的扩展名就是 `.go`。C 文件使用后缀名 `.c`，汇编文件使用后缀名 `.s`。
- 所有的源代码文件都是通过包（packages）来组织。包含可执行代码的包文件在被压缩后使用扩展名 `.a`（AR 文档）。Go 语言的标准库 包文件在被安装后就是使用这种格式的文件。





### 三、Go运行环境与软件安装

#### 1.支持的平台与架构

- Linux 2.6+：amd64、386 和 arm 架构
- Mac OS X（Snow Leopard + Lion）：amd64 和 386 架构
- Windows 2000+：amd64 和 386 架构



#### 2.环境变量

重要的环境变量

- **\$GOROOT** 表示 Go 在你的电脑上的安装位置，它的值一般都是 `/usr/local`。
- **\$GOARCH** 表示目标机器的处理器架构，它的值可以是 386(x86的一部分)、amd64 或 arm。
- **\$GOOS** 表示目标机器的操作系统，它的值可以是 darwin、freebsd、linux 或 windows。
- **\$GOBIN** 表示编译器和链接器的安装位置，默认是 `$GOROOT/bin`
  - 如果是 Go 1.0.3 及以后的版本，一般情况下可以将它的值设置为空，Go 将会使用前面提到的默认值。

- **\$GOHOSTARCH** 表示本地机器的处理器架构，它的值可以是 386(x86的一部分)、amd64 或 arm。
- **\$GOHOSTOS** 表示本地机器的操作系统，它的值可以是 darwin、freebsd、linux 或 windows。

- **\$GOPATH** 表示 Go 的工作区（可以自定义在$HOME/go），该目录下必须包含三个规定的目录：`src`、`pkg` 和 `bin`，这三个目录分别用于存放源码文件、包文件和可执行文件。
- **\$GOARM** 专门针对基于 arm 架构的处理器，它的值可以是 5 或 6，默认为 6。
- **\$GOMAXPROCS** 用于设置应用程序可使用的处理器个数与核数。

> 备注： `$GOHOSTOS` 和 `$GOHOSTARCH` 这两个变量只有在进行交叉编译的时候才会用到，如果不进行设置，它们的值会和`$GOOS` 和 `$GOARCH`一样。



#### 3.安装Go

默认操作系统为Ubuntu。

##### 1）安装 C 工具

Go 的工具链是用 C 语言编写的，因此在安装 Go 之前你需要先安装相关的 C 工具。

```shell
sudo apt-get install bison ed gawk gcc libc6-dev make
```

##### 2）安装golang

如果要从旧版本的Go升级，则必须先[删除现有版本](https://golang.org/doc/install#uninstall)。

- apt-get安装

  ```shell
  sudo apt-get install golang
  
  go version	#查看版本
  ```

  $GOPATH工作区在：/usr/share/go（是/usr/share/go-1.x的软链接）

- 下载二进制文件安装

  从 [官方页面](https://golang.org/dl/) 下载 Go 的二进制软件到计算机上

  ```shell
  wget https://dl.google.com/go/go1.13.4.linux-amd64.tar.gz
  sudo tar -zxvf go1.13.4.linux-amd64.tar.gz -C /usr/local
  ```

  添加/usr/loacl/go/bin目录到PATH变量中

  ```shell
  sudo vim /etc/profile
  	# 在末尾加入
  	export GOROOT=/usr/local/go
  	export PATH=$PATH:$GOROOT/bin
  source /etc/profile
  
  go version
  ```

- 获取 Go 源代码编译安装

  如果二进制分行版不适用于当前操作系统和体系结构的组合，可以从 [官方页面](https://golang.org/dl/) 下载 Go 的源码包到计算机上，然后将解压后的目录 `go` 通过命令移动到 `$GOROOT` 所指向的位置。

    ```shell
  wget https://dl.google.com/go/go1.13.4.src.tar.gz
  sudo tar -zxvf go1.13.4.src.tar.gz -C /usr/local
    ```
  
   编译源代码
  
    ```shell
    cd /usr/local/go/src
    ./all.bash		# 包含安装测试
    # 或
    ./make.bash 	# 仅构建
    ```
  
    Go 安装目录（`$GOROOT`）的文件夹结构：
  
    - `/bin`：包含可执行文件，如：编译器，Go 工具
      - `/doc`：包含示例程序，代码工具，本地文档等
      - `/lib`：包含文档模版
      - `/misc`：包含与支持 Go 编辑器有关的配置文件以及 cgo 的示例
      - `/os_arch`：包含标准库的包的对象文件（`.a`）
      - `/src`：包含源代码构建脚本和标准库的包的完整源代码（Go 是一门开源语言）
      - `/src/cmd`：包含 Go 和 C 的编译器和命令行脚本

##### 3）创建工作区并测试

- 创建工作区目录，建议为$HOME/go

  ```shell
  mkdir $home/go
  ```

- 将工作区路径声明到环境变量中

  ```shell
  sudo vim /etc/profile
  	# 在末尾加入
  	export GOPATH=$home/go
  source /etc/profile
  ```

- 创建一个工程目录

  ```shell
  mkdir -p $GOPATH/src/hello
  ```

- 在src/hello目录下创建hello.go代码文件。

  ```shell
  package main
  
  import "fmt"
  
  func main() {
  	fmt.Printf("hello, world\n")
  }
  ```

- 编译并安装hello.go

  ```shell
  cd $GOPATH/src/hello/
  go install
  	# 编译安装成功，会出现$GOPATH/bin/文件夹和hello可执行文件
  ```

- 执行hello

  ```
  cd $GOPATH/bin/
  ./hello
  ```

  

#### 4.Go runtime 虚拟机

​	尽管 Go 编译器产生的是本地可执行代码，这些代码仍旧运行在 Go 的 runtime当中（在目录 $GOROOT/src/runtime中找到相关内容）。

​	这个 runtime 类似 Java 和 .NET 语言所用到的虚拟机，它负责管理包括内存分配、垃圾回收、栈处理、goroutine、channel、切片（slice）、map 和反射（reflection）等等。

​	Go 的可执行文件都比相对应的源代码文件要大很多，这说明了 Go 的 runtime 嵌入到了每一个可执行文件当中。Go 不需要依赖任何其它文件，它只需要一个单独的静态文件。

##### 1）垃圾回收器

- Go 拥有简单却高效的标记-清除回收器。它的主要思想来源于 IBM 的可复用垃圾回收器，旨在打造一个高效、低延迟的并发回收器。

- 目前 gccgo 编译器还没有回收器。

##### 2）Goroutine 并行设计

Goroutine能够让程序以异步的方式运行，不需要担心一个函数导致程序中断，因此Go也非常适合网络服务。

Goroutine是类似线程的概念（但Goroutine并不是线程）。

- 线程属于系统层面，通常来说创建一个新的线程会消耗较多的资源且管理不易。
- Goroutine就像轻量级的线程，但我们称其为并发，一个Go程序可以运行超过数万个 Goroutine，并且这些性能都是原生级的，随时都能够关闭、结束。
- 一个核心里面可以有多个Goroutine，透过GOMAXPROCS参数能够限制Gorotuine可以占用几个系统线程来避免失控。

**程序并行示例**

```go
// 程序顺序执行
func main() {
    // 假設 loop 是一個會重複執行十次的迴圈函式。
    // 迴圈執行完畢才會往下執行。
    loop()
	// 執行另一個迴圈。
	loop()
}
```

```go
// 程序并行执行
func main() {
    // 透過 `go`，我們可以把這個函式同步執行，
    // 如此一來這個函式就不會阻塞主程式的執行。
    go loop()
	// 執行另一個迴圈。
	loop()
}
```

Go让其中一个函数同步运行，如此就不需要等待该函数运行完后才能运行下一个函数。



#### 5.Go 解析器【了解】

[Go 解释器](https://github.com/sbinet/igo)

类似于python解析器，可以让go程序像脚本语言一样逐行编译和执行。



#### 6. IDE

[IDEs and Plugins for Go](https://github.com/golang/go/wiki/IDEsAndTextEditorPlugins)

##### 1）LiteIDE

LiteIDE 是一款非常好用的轻量级 Go 集成开发环境（基于 QT、Kate 和 SciTE），包含了跨平台开发及其它必要的特性，对代码编写、自动补全和运行调试都有极佳的支持。它采用了 Go 项目的概念来对项目文件进行浏览和管理，它还支持在各个 Go 开发环境之间随意切换以及交叉编译的功能。

同时，它具备了抽象语法树视图的功能，可以清楚地纵览项目中的常量、变量、函数、不同类型以及他们的属性和方法。

可以从 [GitHub](https://github.com/visualfc/liteide) 页面获取详情。

##### 2）GoClipse

其依附于著名的 Eclipse 这个大型开发环境，虽然需要安装 JVM 运行环境，但却可以很容易地享有 Eclipse 本身所具有的诸多功能。这是一个非常好的编辑器，完善的代码补全、抽象语法树视图、项目管理和程序调试功能。

可以从 [GitHub](https://github.com/GoClipse/goclipse) 页面获取详情。



#### 7.格式化工具

`go fmt`（`gofmt`）这个工具可以将源代码格式化成符合官方统一标准的风格，属于语法风格层面上的小型重构。遵循统一的代码风格是 Go 开发中无可撼动的铁律，因此你必须在编译或提交版本管理系统之前使用 `gofmt` 来格式化你的代码。

```shell
# 格式化源文件的代码
gofmt –w program.go
	# 不加参数 -w 则只会打印格式化后的结果而不重写文件
	
# 格式化并重写所有 Go 源文件
gofmt -w *.go

# 会格式化并重写 map1 目录及其子目录下的所有 Go 源文件
gofmt map1 
```



#### 8.代码文档生成器

`go doc` 工具会从 Go 程序和包文件中提取顶级声明的首行注释以及每个对象的相关注释，并生成相关文档。

```shell
go doc package # 获取包的文档注释，例如：go doc fmt 会显示使用 godoc 生成的 fmt 包的文档注释。
go doc package/subpackage # 获取子包的文档注释，例如：go doc container/list。
go doc package function # 获取某个函数在某个包中的文档注释，例如：go doc fmt Printf 会显示有关 fmt.Printf() 的使用说明。
```

这个工具只能获取在 Go 安装目录下 `../go/src` 中的注释内容。

它还可以作为一个本地文档浏览 web 服务器。在命令行输入 `godoc -http=:6060`，然后使用浏览器打开 [http://localhost:6060](http://localhost:6060/) 后，就可以看到本地文档浏览服务器提供的页面。



#### 9.其他工具

- `go install` 是安装 Go 包的工具。主要用于安装非标准库的包文件，将源代码编译成对象文件。
  - go build ：用于编译包，生成可执行文件，必须有main包才可以（package main）。
  - go install ：主要用来生成库和工具
    - (如果有main包)编译后生成的可执行工具文件放到 bin 目录（$GOPATH/bin）；
    - 编译后的库文件放到 pkg 目录下（$GOPATH/pkg)
  - go run ：编译并直接运行程序，它会产生一个临时文件（不会在$GOPATH/bin生成可执行文件），直接在命令行输出程序执行结果，方便用户调试。
- `go fix` 用于将你的 Go 代码从旧的发行版迁移到最新的发行版，它主要负责简单的、重复的、枯燥无味的修改工作，如果像 API 等复杂的函数修改，工具则会给出文件名和代码行数的提示以便让开发人员快速定位并升级代码。`go fix` 之所以能够正常工作是因为 Go 在标准库就提供生成抽象语法树和通过抽象语法树对代码进行还原的功能。该工具会尝试更新当前目录下的所有 Go 源文件，并在完成代码更新后在控制台输出相关的文件名称。
- `go test` 是一个轻量级的单元测试框架。



### 四、首个Go程序和库

#### 1.第一个Go程序

> 参考：[golang-examples](https://github.com/SimonWaldherr/golang-examples)

- 在工作区$GOPATH创建相应的包目录

  ```shell
  mkdir $GOPATH/src/github.com/user/hello
  ```

- 新建hello.go文件

  ```go
  package main	//必须包含main包
  
  import "fmt"
  
  func main() {
  	fmt.Println("Hello, World")
  }
  ```

- 用go 工具编译与安装程序

  ```shell
  go install github.com/user/hello	# 可以在任意路径下执行，会根据环境变量$GOPATH检索
  
  # 如果在包的路径下，可以直接install
  cd $GOPATH/src/github.com/user/hello
  go install 
  ```

- 运行程序

  ```shell
  $ $GOPATH/bin/hello
  Hello, world.
  ```

注意：可以将第3、第4步简化为go run github.com/user/hello



#### 2.第一个Go Library

参考：[Golang标准库](https://github.com/polaris1119/The-Golang-Standard-Library-by-Example)

- 在工作区$GOPATH创建相应的包目录

  ```shell
  mkdir $GOPATH/src/github.com/user/stringutil
  ```

- 新建`reverse.go` 文件

  无需包含main包

  ```go
  // Package stringutil contains utility functions for working with strings.
  package stringutil
  
  // Reverse returns its argument string reversed rune-wise left to right.
  func Reverse(s string) string {
  	r := []rune(s)
  	for i, j := 0, len(r)-1; i < len(r)/2; i, j = i+1, j-1 {
  		r[i], r[j] = r[j], r[i]
  	}
  	return string(r)
  }
  ```

- 测试Go库

  ```shell
  cd $GOPATH/src/github.com/user/stringutil
  go build
  ```

- 修改上述的hello.go文件，调用Go库

  ```go
  package main
  
  import (
  	"fmt"
  
  	"github.com/user/stringutil"	//导入库
  )
  
  func main() {
  	fmt.Println(stringutil.Reverse("!oG ,olleH"))
  }
  ```

- 编译安装运行hello.go

  ```shell
  go install github.com/user/hello
  $GOPATH/bin/hello
  ```

  