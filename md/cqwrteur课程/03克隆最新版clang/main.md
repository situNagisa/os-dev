# 克隆clang
## 目录结构
clang工具链放在toolchains/llvm下  
&emsp;home  
&emsp;&emsp;|——toolchains  
&emsp;&emsp;|&emsp;&emsp;&emsp;|——llvm  
&emsp;&emsp;|&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;|——arch-platform-libc  
&emsp;&emsp;|——toolchains_build   
```shell
mkdir $TOOLCHIANSPATH/llvm
```
## linux
获取clang
```shell
cd $TOOLCHIANSPATH/llvm
wget https://github.com/trcrsired/llvm-releases/releases/download/llvm20-20240827/x86_64-generic-linux-gnu.tar.xz
tar -xvf ./x86_64-generic-linux-gnu.tar.xz -C .
```
导出环境变量
```shell
get_toolchains
```
测试
```shell
clang++ --version
# clang version 20.0.0git (git@github.com:trcrsired/llvm-project.git ef0f86cf7bcc0e65f3a7955c54e73a7257d72181)
# Target: x86_64-generic-linux-gnu
# Thread model: posix
# InstalledDir: /home/nagisa/toolchains/llvm/x86_64-generic-linux-gnu/llvm/bin
```
## windows
获取clang
```shell
cd $TOOLCHIANSPATH/llvm
wget https://github.com/trcrsired/llvm-releases/releases/download/llvm20-20240827/x86_64-windows-gnu.tar.xz
# 里面有一些软硬链接，所以要用管理员模式解压这个压缩包
# 解压后把llvm/bin ,x86_64-windows-gnu/bin , compiler-rt/bin 加到windows的环境变量里
```
测试
```shell
clang++ --version
# clang version 20.0.0git (git@github.com:trcrsired/llvm-project.git f5d58b4ad75c4501c45e25b42980f46718566c98)
# Target: x86_64-unknown-windows-gnu
# Thread model: posix
# InstalledDir: C:/workspace/app/toolchains/llvm/x86_64-windows-gnu/llvm/bin
cppwinrt -v
# tool:  C:\workspace\app\toolchains\llvm\x86_64-windows-gnu\x86_64-windows-gnu\bin\cppwinrt.exe
# ver:   2.3.4.5
# out:   C:\workspace\project\temp\
# time:  6ms
```