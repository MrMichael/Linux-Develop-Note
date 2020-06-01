[TOC]

> 参考：[the-way-to-go_ZH_CN](https://github.com/unknwon/the-way-to-go_ZH_CN)、[books.studygolang.com](https://books.studygolang.com/gopl-zh/ch2/ch2.html)





## 一、文件名、关键字与标识符

- 文件名以.go结尾

- 标识符与 C 家族中的其它语言相同。

   36 个预定义标识符

  | append | bool    | byte    | cap     | close  | complex | complex64 | complex128 | uint16  |
  | ------ | ------- | ------- | ------- | ------ | ------- | --------- | ---------- | ------- |
  | copy   | false   | float32 | float64 | imag   | int     | int8      | int16      | uint32  |
  | int32  | int64   | iota    | len     | make   | new     | nil       | panic      | uint64  |
  | print  | println | real    | recover | string | true    | uint      | uint8      | uintptr |

- 25个关键字

  | break    | default     | func   | interface | select |
  | -------- | ----------- | ------ | --------- | ------ |
  | case     | defer       | go     | map       | struct |
  | chan     | else        | goto   | package   | switch |
  | const    | fallthrough | if     | range     | type   |
  | continue | for         | import | return    | var    |

- golang程序规范
  - 命名使用驼峰命名法，且不能出现下划线
  - 根据首字母的大小写来确定访问权限。无论是方法、常量、变量或结构体的名称。
    - 如果使用首字母大写，则可以被其他包访问
    - 如果首字母小写，则只能在本包中使用。
  - 结构体中属性名的大写，如果属性名小写，则会在数据解析时（如json解析或将结构体作为请求或访问参数）时无法解析。



## 二、基本结构和要素

```go
package main	//归属于main包

import "fmt"	// 导入 fmt 包（函数或其他元素）

//实现main包中的main函数，该函数会自动执行
func main() {
	fmt.Println("hello, world")  // fmt 包中的 Println 函数，可以将字符串输出到控制台，并在最后自动增加换行字符 \n
}
```



### 1.包的概念、导入与可见性

#### 1）文件的归属与包的导入

- 源文件中非注释的第一行指明这个文件属于哪个包，如：`package main`。
  - `package main`表示一个可独立执行的程序，不指定属于main包的源程序，则会被编译为包（所有的包名都应该使用小写字母）。
  - 可以用一些较小的文件，并且在每个文件非注释的第一行都使用 `package main` 来指明这些文件都属于 main 包。

- Go 程序是通过 `import` 关键字导入一组包，包名被封闭在半角双引号 `""` 中。

  ```go
  //import "包的路径或 URL 地址" 
  import "fmt"
  import "os"
  
  // 或
  import (
     "fmt"
     "os"
  )	// 被称为因式分解关键字
  
  //导入外部安装包
  	//先安装外部包到 $GOROOT/src/ 目录
  go install codesite.ext/author/goExample/goex
  import goex "codesite.ext/author/goExample/goex"
  ```

  - 包在导入是可以使用相对路径或绝对路径
  - 如果想要构建一个程序，则包和包内的文件都必须以正确的顺序进行编译。包的依赖关系决定了其构建顺序。

- Go 的标准库包含了大量的包（如：fmt 和 os），存放在 `$GOROOT/pkg/$GOOS_$GOARCH/` 目录下。

  - `os`: 提供一个平台无关性的操作系统功能接口，采用类Unix设计，隐藏了不同操作系统间差异，让不同的文件系统和操作系统对象表现一致。
  - `os/exec`: 提供运行外部操作系统命令和程序的方式。
  - `syscall`: 底层的外部包，提供了操作系统底层调用的基本接口。

- 同一个包的源文件必须全部被一起编译。
  
  - 对一个包进行更改或重新编译，所有引用了这个包的程序都必须全部重新编译。

#### 2）可见性规则

- 当标识符（包括常量、变量、类型、函数名、结构字段等等）以一个大写字母开头，如：Group1，那么使用这种形式的标识符的对象就可以被外部包的代码所使用（客户端程序需要先导入这个包），这被称为导出（像面向对象语言中的 public）；
- 标识符如果以小写字母开头，则对包外是不可见的，但是他们在整个包的内部是可见并且可用的（像面向对象语言中的 private ）。

#### 3）包的分级声明和初始化

- 包内可以定义或声明 0 个或多个常量（const）、变量（var）和类型（type），这些对象的作用域都是全局的（在本包范围内）。



### 2.注释

- 单行注释以 `//` 开头。
- 多行注释均以 `/*` 开头，并以 `*/` 结尾。
- 每一个包应该有相关注释，在 package 语句之前的块注释将被默认认为是这个包的文档说明
- 所有全局作用域的类型、常量、变量、函数和被导出的对象都应该有一个合理的注释。
- godoc 工具会收集这些注释并产生一个技术文档。



### 3.打印

[Go中的fmt几种输出的区别和格式化方式](https://blog.csdn.net/a953713428/article/details/90112521)

fmt包有printf与println两个打印函数

- Println :可以打印字符串和变量

  ```go
  a := 10
  fmt.Println(a)　
  fmt.Println("abc")
  ```

- Printf : 可以打印出格式化的字符串，可以输出字符串类型的变量，不可以输出其他类型变量

  ```go
  fmt.Printf("%v", str)
  
  //通用的占位符
  %v     值的默认格式。
  %+v   类似%v，但输出结构体时会添加字段名
  %#v　 相应值的Go语法表示 
  %T    相应值的类型的Go语法表示 
  %%    百分号,字面上的%,非占位符含义
  
  //默认格式%v下，对于不同的数据类型，底层会去调用默认的格式化方式：
  bool:                    %t 
  int, int8 etc.:          %d 
  uint, uint8 etc.:        %d, %x if printed with %#v
  float32, complex64, etc: %g
  string:                  %s
  chan:                    %p 
  pointer:                 %p
  ```



### 4.变量、常量和类型

Go语言变量和常量的声明方式与C和C++语言明显不同， Go语言引入了关键字var，而类型信息放在变量或常量名之后。

#### 1）变量

- 变量的声明

  ```go
  var v1 int
  var v2 string
  var v3 [10]int // 数组
  var v4 []int // 数组切片
  var v5 struct {
  f int
  }
  var v6 *int // 指针
  var v7 map[string]int // map， key为string类型， value为int类型
  var v8 func(a int) int
  ```

  - Go 语言不使用分号作为语句的结束，实际上这一过程是由编译器自动完成。

- 变量的声明及初始化

  ```go
  //  var关键字可以保留，但不再是必要的元素
  var v1 int = 10 // 正确的使用方式1
  var v2 = 10 // 正确的使用方式2，编译器可以自动推导出v2的类型
  v3 := 10 // 正确的使用方式3，编译器可以自动推导出v3的类型
  	// :=左侧的变量不应该是已经被声明过的，否则会导致编译错误
  ```

- 变量的赋值

  ```go
  var v10 int
  v10 = 123
  ```

- 变量匿名

  在调用函数时为了获取一个值，却因为该函数返回多个值而不得不定义一堆没用的变量。Go可以通过结合使用多重返回和匿名变量来避免这种丑陋的写法

  ```go
  func GetName() (firstName, lastName, nickName string) {
  	return "May", "Chan", "Chibi Maruko"
  }
  _, _, nickName := GetName()
  ```

#### 2）常量

- 常量的声明及初始化

  ```go
  const Pi float64 = 3.14159265358979323846
  const zero = 0.0 // 无类型浮点常量
  const (
      size int64 = 1024
      eof = -1 // 无类型整型常量
  )
  const u, v float32 = 0, 3 // u = 0.0, v = 3.0，常量的多重赋值
  const a, b, c = 3, 4, "foo"
  // a = 3, b = 4, c = "foo", 无类型整型和字符串常量
  ```

- 预定义常量： true、 false和iota。

  ```go
  //iota被认为是一个可被编译器修改的常量，在每一个const关键字出现时被重置为0，然后在下一个const出现之前，每出现一次iota，其所代表的数字会自动增1。
  const ( // iota被重设为0
      c0 = iota // c0 == 0
      c1 = iota // c1 == 1
      c2 = iota // c2 == 2
  )
  
  const (
      u = iota * 42 // u == 0
      v float64 = iota * 42 // v == 42.0
      w = iota * 42 // w == 84
  )
  
  //如果两个const的赋值语句的表达式是一样的，那么可以省略后一个赋值表达式。
  const ( // iota被重设为0
      c0 = iota // c0 == 0
      c1 // c1 == 1
      c2 // c2 == 2
  )
  ```

#### 3）类型

- 基础类型

  - 布尔类型： bool
  - 整型： int8、 byte、 int16、 int、 uint、 uintptr等
  - 浮点类型： float32、 float64。
  - 复数类型： complex64、 complex128。
  - 字符串： string。
  - 字符类型： rune。
  - 错误类型： error。

- 复合类型

  - 指针（pointer）

  - 数组（array）

    ```go
    //数组（array）
    var a [3]int
  var b [3]int = [3]int{1, 2, 3}
    c := [...]int{1, 2}
  fmt.Println(a[0]) 
    //二维数组
  d := [3][5]int
    d[0][1] = 0
    ```

  - 切片（slice）

    - Slice（切片）代表变长的序列，序列中每个元素都有相同的类型。一个slice类型一般写作[]T，其中T代表slice中元素的类型；slice的语法和数组很像，只是没有固定长度而已。

      ```go
      //声明切片的格式
      var identifier []type   //不需要说明长度
      d := [...]int{1, 2,3,4,5,6,7,8,9}
      var slice1 []int = d[2:5]
    
      //用 make() 创建一个切片
    slice1 := make([]int, 50, 100)
      //用 new() 创建一个切片
      slice2 := new([100]int)[0:50]
      ```

  - 字典（map）

    - map类型可以写为map[K]V，其中K和V分别对应key和value。

      ```go
      ages := map[string]int{
          "alice":   31,
          "charlie": 34,
      }
      ages["alice"] = 32
      fmt.Println(ages["alice"]) // "32"
      ```

  - 通道（chan）

  - 结构体（struct）

    ```go
    type Employee struct {
        ID        int					//编译器在行末自动添加逗号
        Name      string	
        Address   string
        DoB       time.Time
        Position  string
        Salary    int
        ManagerID int
    }
    var dilbert Employee
    ```

  - 接口（interface）

  - JSON

    - JavaScript对象表示法（JSON）是一种用于发送和接收结构化信息的标准协议。JSON是对JavaScript中各种类型的值（字符串、数字、布尔值）和对象（Unicode本文）的编码。

      ```go
      //1.编组（marshaling）：结构体slice转为JSON格式数据
      type Movie struct {
          Title  string
          Year   int  `json:"released"`
          Color  bool `json:"color,omitempty"`
          Actors []string
      }
      
      var movies = []Movie{
          {Title: "Casablanca", Year: 1942, Color: false,
              Actors: []string{"Humphrey Bogart", "Ingrid Bergman"}},
          {Title: "Cool Hand Luke", Year: 1967, Color: true,
              Actors: []string{"Paul Newman"}},
          {Title: "Bullitt", Year: 1968, Color: true,
              Actors: []string{"Steve McQueen", "Jacqueline Bisset"}},
          // ...
      }
      
      data, err := json.Marshal(movies)
      if err != nil {
          log.Fatalf("JSON marshaling failed: %s", err)
      }
      fmt.Printf("%s\n", data)
      //打印结果
      [{"Title":"Casablanca","released":1942,"Actors":["Humphrey Bogart","Ingr
      id Bergman"]},{"Title":"Cool Hand Luke","released":1967,"color":true,"Ac
      tors":["Paul Newman"]},{"Title":"Bullitt","released":1968,"color":true,"
      Actors":["Steve McQueen","Jacqueline Bisset"]}]
                                                       
      //2.将JSON格式数据解码为一个结构体slice
      var titles []struct{ Title string }
                                                       
      if err := json.Unmarshal(data, &titles); err != nil {
      	log.Fatalf("JSON unmarshaling failed: %s", err)
      }
      fmt.Println(titles) // "[{Casablanca} {Cool Hand Luke} {Bullitt}]"                
      ```

#### 4）自定义类型

使用关键字type自定义类型

```go
//自定义类型
type IZ int
var a IZ = 5

//定义多类型，使用因式分解关键字的方式
type (
   IZ int
   FZ float64
   STR string
)
```

#### 5）类型转换

```go
//int与float转换
var a float32 = 1234.12345678
b := int64(a)
c := float32(a)
d := float64(a)
e := float64(c)

// []byte转int（16进制转10进制）
import "fmt"
import "encoding/binary"
var a []byte = []byte{0, 1, 2, 3}  
binary.BigEndian.Uint32(a)		//0x00010203 ==> 66051
binary.LittleEndian.Uint32(a) //0x03020100 ==> 50462976

// []byte -> String  (byte转ascii)
data1 := []byte{0x31, 0x32, 0x33, 0x34}
data2 := []byte("Hello")
str1 := string(data1)  //"1234"
str2 := string(data2)  //"Hello"
// []byte -> String  (byte转hex)
import "encoding/hex"
hexstr := hex.EncodeToString(data1)     //"31323334"
// String -> []byte (hex转byte)
tmp, _ := hex.DecodeString(hexstr)  //[49 50 51 52]


//===strconv包实现基本数据类型的字符串表示形式之间的转换===
import "strconv"
//数值转换
	//int转string
	strconv.Itoa(i int) string
	//string转int
	strconv.Atoi(s string) (i int, err error)
//将字符串转换为值
	//string转bool
    b, err := strconv.ParseBool("true")
	//string转float64
    f, err := strconv.ParseFloat("3.1415", 64)
	//string转int64，10进制表示
    i, err := strconv.ParseInt("-42", 10, 64)
	//string转uint64
    u, err := strconv.ParseUint("42", 10, 64)
//将值转换为字符串
	//bool转string
	s := strconv.FormatBool(true)
	//float64转string 64
    s := strconv.FormatFloat(3.1415, 'E', -1, 64)
	//int64转string，以10进制显示
    s := strconv.FormatInt(-42, 10)
	//uint64转string，以10进制显示
    s := strconv.FormatUint(42, 10)

```



### 5.运算符

- 数值运算

- 比较运算

  ==`、`!=`、`<`、`<=`、`>`、`>=

- 位运算

  按位与 `&`、按位或 `|`、按位异或 `^`、

- 字符串操作

  ```go
  //字符串拼接
  s := "hel" + "lo,"
  s += "world!"
  strings.Join(sl []string, sep string) string
  //字符串分割
  //将会利用 1 个或多个空白符号来作为动态长度的分隔符将字符串分割成若干小块
  sl := strings.Fields(str)
  for _, val := range sl {
      fmt.Printf("%s - ", val)
  }
  //自定义分割符号来对指定字符串进行分割
  sl2 := strings.Split(str2, "|")
  for _, val := range sl2 {
      fmt.Printf("%s - ", val)
  }
  
  //判断前缀
  strings.HasPrefix(str, "Th") bool
  //判断后缀
  strings.HasSuffix(str, "er")  bool
  
  //字符串包含关系
  strings.Contains(str, substr)  bool
  
  //判断子字符串或字符在父字符串中首次出现的位置
  strings.Index(s, str string)  int
  //判断子字符串或字符在父字符串中最后出现的位置
  strings.LastIndex(s, str string) int
  
  //字符串替换
  //将字符串 str 中的前 n 个字符串 old 替换为字符串 new,  n = -1 则替换所有字符
  strings.Replace(str, old, new, n) string
  
  //统计字符串出现次数
  strings.Count(s, str) int
  
  //修改字符串大小写
  strings.ToLower(s) string
  strings.ToUpper(s) string
  ```



### 6.Go 程序的一般结构示例

```go
package main  //被 main 包引用，是一个可独立执行的程序

import (
   "fmt"
)

const c = "C"

var v int = 5

type T struct{}

//每个源文件都只能包含一个 init 函数, 执行优先级比 main 函数高
func init() { // initialization of package
}

func main() {
   var a int
   Func1()
   // ...
   fmt.Println(a)
}

func (t T) Method1() {
   //...
}

func Func1() { // exported function Func1
   //...
}
```

Go 程序的执行顺序：

1. 按顺序导入所有被 main 包引用的其它包，然后在每个包中执行如下流程：
2. 如果该包又导入了其它的包，则从第一步开始递归执行，但是每个包只会被导入一次。
3. 然后以相反的顺序在每个包中初始化常量和变量，如果该包含有 init 函数的话，则调用该函数。
4. 在完成这一切之后，main 也执行同样的过程，最后调用 main 函数开始执行程序。





## 三、控制结构

### 1.if-else

```go
if condition1 {
	// do something	
} else if condition2 {
	// do something else	
} else {
	// catch-all or default
}

//示例
func main() {
	var first int = 10
	var cond int

	if first <= 0 {
		fmt.Printf("first is less than or equal to 0\n")
	} else if first > 0 && first < 5 {
		fmt.Printf("first is between 0 and 5\n")
	} else {
		fmt.Printf("first is 5 or greater\n")
	}
	if cond = 5; cond > 10 {
		fmt.Printf("cond is greater than 10\n")
	} else {
		fmt.Printf("cond is not greater than 10\n")
	}
}
```



### 2.switch

```go
// 方式1
switch var1 {
	case val1:
		...
	case val2:
		...
	default:
		...
}

//示例
func main() {
	var num1 int = 100

	switch num1 {
	case 98, 99:
		fmt.Println("It's equal to 98")
	case 100: 
		fmt.Println("It's equal to 100")
	default:
		fmt.Println("It's not equal to 98 or 100")
	}
}

//方式2
switch {
	case condition1:
		...
	case condition2:
		...
	default:
		...
}

//示例
func main() {
	var num1 int = 7

	switch {
	    case num1 < 0:
		    fmt.Println("Number is negative")
	    case num1 > 0 && num1 < 10:
		    fmt.Println("Number is between 0 and 10")
	    default:
		    fmt.Println("Number is 10 or greater")
	}
}
```



### 3.for

```go
// 格式
for 初始化语句; 条件语句; 修饰语句 {
    	// do something	
}

//示例
func main() {
	for i := 0; i < 5; i++ {
		fmt.Printf("This is the %d iteration\n", i)
	}
}

//for-range 结构
for i, char := range str {
	...
}
//示例
func main() {
	str := "Go is a beautiful language!"
	fmt.Printf("The length of str is: %d\n", len(str))
	for pos, char := range str {
		fmt.Printf("Character on position %d is: %c \n", pos, char)
	}
}
```



## 四、函数

Go 里面有三种类型的函数：

- 普通的带有名字的函数
- 匿名函数或者lambda函数
- 方法（Methods）

### 1.普通函数

```go
//普通函数格式
	// 入口参数：parameter_list 的形式为 (param1 type1, param2 type2, …)
	// 回调参数： return_value_list 的形式为 (ret1 type1, ret2 type2, …)
func functionName(parameter_list) (return_value_list) {
   …
}

//示例
func Atoi(s string) (i int, err error)
//调用
num, err := Atoi("12")

//自定义一个函数类型别名
type name func(type1,type2) type3
//示例
type binOp func(int, int) int
add := binOp
```

- 左大括号 `{` 必须与方法的声明放在同一行，这是编译器的强制规定，大括号 `{}` 的使用规则在任何时候都相同。
- 函数也是一个类型，可以作为参数



### 2.匿名函数

```go
func(parameter_list) (return_value_list) {...}
//示例
fplus := func(x, y int) int { return x + y }
num := fpus(1,2)
```

- 匿名函数不能够独立存在，但可以被赋值于某个变量



### 3.方法

[什么是面向对象编程思想？](https://www.zhihu.com/question/31021366)

面向对象编程（OOP）把对象作为程序的基本单元，一个对象包含了数据和操作数据的函数。把程序视为一组对象的集合，而每个对象都可以接收其他对象发过来的消息，并处理这些消息，程序的执行就是一系列消息在各个对象之间传递。



## 五、数组与切片

声明数组的格式是： `var identifier [n]type`

把一个大数组传递给函数会消耗很多内存。有两种方法可以避免这种现象：

- 传递数组的指针
- 使用数组的切片



切片（slice）是对数组一个连续片段的引用，这个片段可以是整个数组，或者是由起始和终止索引标识的一些项的子集。多个切片如果表示同一个数组的片段，它们可以共享数据；因此一个切片和相关数组的其他切片是共享存储的。

- 声明切片的格式： `var identifier []type`，一个切片在未初始化之前默认为 nil，长度为 0。

- 切片的初始化格式：`var slice1 []type = arr1[start:end]`

  - `arr1[2:]` 和 `arr1[2:len(arr1)]` 相同，都包含了数组从第三个到最后的所有元素。

    `arr1[:3]` 和 `arr1[0:3]` 相同，包含了从第一个到第三个元素（不包括第三个）。



### 1.new() 和 make() 的区别

- func new(Type) *[Type]：内置函数 new 会分配内存。第一个参数是一个类型，而不是值，并且返回值是一个指向该类型零值的指针。

  ```go
  var p *[]int = new([]int) // *p == nil; with len and cap 0
  ```

- func *make*(t [Type](https://www.bookstack.cn/read/gctt-godoc/Translate-builtin-builtin.md#Type), size ...[IntegerType](https://www.bookstack.cn/read/gctt-godoc/Translate-builtin-builtin.md#IntegerType)) [Type](https://www.bookstack.cn/read/gctt-godoc/Translate-builtin-builtin.md#Type) ：内置函数 *make* 分配并初始化 slice，map 或者 chan。和 new 类似，第一个参数为参数的类型，而不是一个值。和 new 不同的是 *make* 返回的类型和参数类型相同，而不是一个指向该类型的指针。

  ```go
  //分配一个有 50 个 int 值的数组，并且创建了一个长度为 10，容量为 50 的 切片 v，该 切片 指向数组的前 10 个元素。
  var v []int = make([]int, 10, 50) 
  //slice1 := make([]type,init_length, capacity)
  ```



### 2.For-range 结构

```go
//这种构建方法可以应用于字符串（本质是字节数组）、数组和切片
for ix, value := range slice1 {
    ...
}
```



### 3.切片的复制与追加

如果想增加切片的容量，我们必须创建一个新的更大的切片并把原分片的内容都拷贝过来。

```go
//复制切片
sl_from := []int{1, 2, 3}
sl_to := make([]int, 10)
n := copy(sl_to, sl_from)

//追加切片
sl3 := []int{1, 2, 3}
sl3 = append(sl3, 4, 5, 6)
```

append 方法将 0 个或多个具有相同类型 s 的元素追加到切片后面并且返回新的切片

如果 s 的容量不足以存储新增元素，append 会分配新的切片来保证已有切片元素和新增元素的存储。



## 六、Map

map 是一种特殊的数据结构：一种元素对（pair）的无序集合，pair 的一个元素是 key，对应的另一个元素是 value，所以这个结构也称为关联数组或字典。



### 1.概念

#### 1）map的声明及初始化

```go
var map1 map[keytype]valuetype

var mapLit map[string]int
mapLit = map[string]int{"one": 1, "two": 2}

//通过make函数初始化
var map1 = make(map[keytype]valuetype)
```

- 在声明的时候不需要知道 map 的长度，map 是可以动态增长的。

- key 可以是任意可以用 == 或者 != 操作符比较的类型，比如 string、int、float。

- value 可以是任意类型



## 五、包（Package）

### 1.标准库

像 `fmt`、`os` 等这样具有常用功能的内置包在 Go 语言中有 150 个以上。

`unsafe`: 包含了一些打破 Go 语言“类型安全”的命令，一般的程序中不会被使用，可用在 C/C++ 程序的调用中。

`syscall`-`os`-`os/exec`:

- `os`: 提供一个平台无关性的操作系统功能接口，采用类Unix设计，隐藏了不同操作系统间差异，让不同的文件系统和操作系统对象表现一致。
- `os/exec`: 提供运行外部操作系统命令和程序的方式。
- `syscall`: 底层的外部包，提供了操作系统底层调用的基本接口。

[Golang标准库文档](https://studygolang.com/pkgdoc)



### 2.第三方包

[golang 标准库及第三方库文档](https://www.bookstack.cn/books/gctt-godoc)