# 为什么要使用交叉编译器

本文为osdev的[Why do I need a Cross Compiler?](https://wiki.osdev.org/Why_do_I_need_a_Cross_Compiler%3F) 翻译 + 个人理解  

您可以参考[【科普】编译器的构建基本原理](https://zhuanlan.zhihu.com/p/553543765)来了解编译器的基本知识  

你可以通过
```shell
gcc -dumpmachine # x86_64-pc-linux-gnu
```
来查询gcc的目标平台

## 如何构建交叉编译器
您可以参考：
* [gcc交叉编译器](https://wiki.osdev.org/GCC_Cross_Compiler)
* [构建gcc本地，加拿大编译器](../../cqwrteur课程/02构建gcc本地(加拿大)(交叉)编译器/main.md)

## 过渡到交叉编译器
> 看样子之前很多人用本地编译器去交叉编译，有点神奇的

### 使用交叉编译器去做链接（交链器），而不是本地编译器
> 没什么好说的

### 使用交叉工具
使用cross-binutils而不是本地的binutils

### 编译器选项
应该启用的选项：  
* **-ffreestanding**  
这很重要，因为它让编译器知道它正在构建内核而不是用户空间程序。GCC 的文档说你需要在独立模式下自己实现 memset、memcpy、memcmp 和 memmove 函数。
> 此篇章面向os设计，也就是为裸机写os，裸机自然是没有宿主实现的，开启此选项可以防止不小心调用到宿主的api

* **-mno-red-zone(x86_64 only)**  
您需要在 x86_64 上传递此消息，否则中断会损坏堆栈。红色区域是 x86_64 ABI 功能，这意味着信号发生在堆栈下方 128 字节处。允许使用少于该内存量的函数不递增堆栈指针。这意味着内核中的 CPU 中断会损坏堆栈。请务必为所有内核代码传递 enable this x86_64 。

* **-fno-exceptions, -fno-rtti**   
异常处理与RTTI(run time type info)由libstdc++提供，虽然标准是独立实现，但大多数主流实现是宿主实现，我们给他禁了  
> 关于libstdc++作用可参考[05编译时依赖库](../../cqwrteur课程/05编译时依赖库/main.md)

不应该启用的选项：  
* **-m32, -m64**  
交叉编译器自己知道自己要编译到什么平台，不需要重复指定

* **-nostdinc**  
交叉编译器会根据目标平台提供对应的标准库头
> 可能是早期大多数人不用交叉编译器，用本地编译器的话要重写标准头，但我们用交叉编译器就没这顾虑

* **-fno-builtin**  
由-ffreestanding隐含，不需要再传递一遍  
编译器默认为 -fbuiltin 启用内置函数，但 -fno-builtin 禁用它们。内置意味着编译器了解标准功能并可以优化它们的使用。如果编译器看到一个名为 'strlen' 的函数，它通常假定它是 C 标准的 'strlen' 函数，并且它能够在编译时将表达式 strlen（“foo”） 优化为 3，而不是调用该函数。如果你正在创建一些真正的非标准环境，其中常见的 C 函数没有其通常的语义，那么这个选项是有价值的。可以在 -ffreestanding 之后使用 -fbuiltin 再次启用内置函数，但这可能会导致将来出现令人惊讶的问题，例如将 calloc （malloc + memset） 的实现优化为对 calloc 本身的调用。
> 机翻看不懂，照着做就行了

* **-fno-stack-protector**  
[stack smashing protector](https://wiki.osdev.org/Stack_Smashing_Protector)是一项功能，可在所选函数的堆栈上存储随机值，并在返回时验证该值是否完好无损。这在统计上可以防止堆栈缓冲区溢出覆盖堆栈上的返回指针，否则会破坏控制流。攻击者通常能够利用此类故障，此功能要求攻击者正确猜测 32 位值（32 位系统）或 64 位值（64 位系统）。此安全功能需要运行时支持。许多操作系统供应商的编译器通过将 -fstack-protector 设置为默认值来启用此功能。如果内核没有运行时支持，这会破坏不使用交叉编译器的内核。交叉编译器（如 *-elf 目标）默认禁用堆栈保护程序，没有理由自己禁用它。当您向内核（和用户空间）添加对它的支持时，您可能希望将默认值更改为启用它，这将使它自动被您的内核使用，因为您没有传递此选项。

 
### 链接器选项
> 这些选项仅在链接时有意义（在编译时没有意义）。某些编译选项（例如 -mno-red-zone）控制 ABI，因此在链接时，您也应该传递编译选项。  

应该启用的选项：  
* **-nostdlib(-nostartfiles -nodefaultlibs)**  
-nostdlib 选项与同时传递 -nostartfiles -nodefaultlibs 选项相同。  
某些起始文件 （crt0.o， crti.o， crtn.o）只用于用户空间程序，并且libc是由操作系统提供的，裸机不应该有

* **-lgcc**  
使用-nodefaultlibs时，会把libgcc（编译器运行时）也一起禁用，但是编译器运行是一定要依赖libgcc的，所以我们得显示指明链接
> 关于libgcc，与什么是编译器运行时，可以参考[05编译时依赖库](../../cqwrteur课程/05编译时依赖库/main.md)

不应该启用的选项：  
* **-melf_i386, -melf_x86_64**  
交叉链接器知道自己的目标平台信息，不需要重复指定

### 汇编器选项

不应该启用：  
* **-32， -64**  
交叉汇编器知道自己目标平台架构，不需要重复指定

## 没有交叉编译器时会出现的问题
您需要克服很多问题才能使用系统 gcc 构建内核。如果您使用交叉编译器，则无需处理这些问题。  

### 更复杂的编译指令
本地编译器会根据目标系统（本地）选择对应的默认编译选项，如果我们希望用本地编译器去交叉编译，那么就得手动指定编译选项，这会很麻烦
```shell
 as -32 boot.s -o boot.o
 gcc -m32 kernel.c -o kernel.o -ffreestanding -nostdinc
 gcc -m32 my-libgcc-reimplemenation.c -o my-libgcc-reimplemenation.o -ffreestanding
 gcc -m32 -T link.ld boot.o kernel.o my-libgcc-reimplemenation.o -o kernel.bin -nostdlib -ffreestanding
```
实际上，平均情况更糟。人们倾向于添加更多有问题或多余的选项。使用真正的交叉编译器，命令序列可能如下所示：
```shell
 i686-elf-as boot.s -o boot.o
 i686-elf-gcc kernel.c -o kernel.o -ffreestanding
 i686-elf-gcc -T link.ld boot.o kernel.o -o kernel.bin -nostdlib -ffreestanding -lgcc
```

### 重新实现 libgcc
在构建内核时，不能使用主机 libgcc。上次我检查的 Linux libgcc 有一些令人讨厌的依赖项。新手遇到的常见情况是在 32 位系统上进行 64 位整数除法，但在许多情况下编译器可能会生成此类调用。你经常会重写 libgcc，而你本来应该使用真实的东西。

### 重写独立标头（通常不正确）
本地编译器会使用本地标头，这通常不与目标平台对应，所以需要重写标头  
重写标头是吃力不讨好的事，且不说大多数开发者的能力问题，即便是能力强的开发者来了，也无法做到  
因为有些api是需要编译器开洞实现的，作为开发者我们除了修改编译器源代码以外无法实现

### 版本问题
可能你换个版本的编译器你的系统就编译炸了

## 背景信息

### 什么时候不需要交叉编译器
如果你完成了一个真正的操作系统，并将 gcc 移植到它上面（构建加拿大本地编译器），并且那个 gcc 将产生与 i686-myos-gcc 完全相同的代码。  
这意味着你不需要在自己的操作系统上使用交叉编译器。  
这就是为什么 Linux 内核是使用 Linux gcc 构建的，而不是 Linux 交叉编译器。