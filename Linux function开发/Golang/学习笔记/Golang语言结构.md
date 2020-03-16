[TOC]

> 参考：[the-way-to-go_ZH_CN](https://github.com/unknwon/the-way-to-go_ZH_CN)



### 一、基本结构和基本数据类型

#### 1.文件名、关键字与标识符

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



#### 2.基本结构和要素

```go
package main	// 指明这个文件属于main包

import "fmt"	// 导入 fmt 包（函数或其他元素）

func main() {
	fmt.Println("hello, world")
}
```



##### 1）包的概念、导入与可见性

###### 文件的归属与包的导入

- 源文件中非注释的第一行指明这个文件属于哪个包，如：`package main`。
  - `package main`表示一个可独立执行的程序，不指定属于main包的源程序，则会被编译为包（所有的包名都应该使用小写字母）。
  - 可以用一些较小的文件，并且在每个文件非注释的第一行都使用 `package main` 来指明这些文件都属于 main 包。

- Go 程序是通过 `import` 关键字导入一组包，包名被封闭在半角双引号 `""` 中。

  ```go
  import "fmt"
  import "os"
  
  // 或
  import (
     "fmt"
     "os"
  )	// 被称为因式分解关键字
  ```

  - 包在导入是可以使用相对路径或绝对路径
  - 如果想要构建一个程序，则包和包内的文件都必须以正确的顺序进行编译。包的依赖关系决定了其构建顺序。

- Go 的标准库包含了大量的包（如：fmt 和 os），存放在 `$GOROOT/pkg/$GOOS_$GOARCH/` 目录下。

- 同一个包的源文件必须全部被一起编译。
  - 对一个包进行更改或重新编译，所有引用了这个包的程序都必须全部重新编译。

###### 可见性规则

- 当标识符（包括常量、变量、类型、函数名、结构字段等等）以一个大写字母开头，如：Group1，那么使用这种形式的标识符的对象就可以被外部包的代码所使用（客户端程序需要先导入这个包），这被称为导出（像面向对象语言中的 public）；
- 标识符如果以小写字母开头，则对包外是不可见的，但是他们在整个包的内部是可见并且可用的（像面向对象语言中的 private ）。

###### 包的分级声明和初始化

- 包内可以定义或声明 0 个或多个常量（const）、变量（var）和类型（type），这些对象的作用域都是全局的（在本包范围内）。



##### 2）函数

规范的函数书写形式

```go
func functionName(parameter_list) (return_value_list) {
   …
}
// parameter_list 的形式为 (param1 type1, param2 type2, …)
// return_value_list 的形式为 (ret1 type1, ret2 type2, …)
```

- 左大括号 `{` 必须与方法的声明放在同一行，这是编译器的强制规定，大括号 `{}` 的使用规则在任何时候都相同。

- main 函数是每一个可执行程序所必须包含的，一般来说都是在启动后第一个执行的函数
  - 如果有 init() 函数则会先执行该函数



##### 3）注释

- 单行注释以 `//` 开头。
- 多行注释均以 `/*` 开头，并以 `*/` 结尾。
- 每一个包应该有相关注释，在 package 语句之前的块注释将被默认认为是这个包的文档说明
- 所有全局作用域的类型、常量、变量、函数和被导出的对象都应该有一个合理的注释。
- godoc 工具会收集这些注释并产生一个技术文档。



##### 4）类型

- 基本类型，如：int、float、bool、string；
- 结构化的（复合的），如：struct、array、slice、map、channel；
- 只描述类型的行为的，如：interface。

> 注：Go 语言中不存在类型继承。













