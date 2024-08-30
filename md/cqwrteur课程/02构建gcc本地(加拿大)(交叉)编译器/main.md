# 构建gcc 本地交叉编译器，加拿大本地编译器，加拿大交叉编译器
开始本教程之前，你需要：  
* 阅读[【科普】编译器的构建基本原理](https://zhuanlan.zhihu.com/p/553543765)  
* 完成[ 构建gcc本地编译器](../01构建gcc本地编译器/main.md)

## 构建gcc
导出工具链环境变量
```shell
get_toolchians
```
下载依赖
```shell
# ubuntu
sudo apt install gettext rsync mercurial
# arch linux
sudo pacman -S gettext rsync mercurial
```
克隆glibc
```shell
# 具体版本根据你的目标平台决定，比如我的开发板上的glibc版本是2.35，所以我就下2.35版本
cd $TOOLCHAINS_BUILD
git clone -b release/2.35/master git://sourceware.org/git/glibc.git
```
克隆[cqwrteur的构建脚本](https://github.com/trcrsired/toolchainbuildscripts)
```shell
cd $TOOLCHIANS_BUILD
git clone https://github.com/trcrsired/toolchainbuildscripts.git
```
### 构建linux-windows的交叉编译器与加拿大本地编译器
将会构建:  
* x86_64-pc-linux-gnu -> x86_64-pc-linux-gnu -> x86_64-w64-mingw32 的linux交叉windows的交叉编译器
* x86_64-pc-linux-gnu -> x86_64-w64-mingw32 -> x86_64-w64-mingw32 的加拿大本地编译器
```shell
cd $TOOLCHAINS_BUILD/toolchainbuildscripts/gccbuild/x86_64-w64-mingw32/
CLONE_ON_CHINA=yes ./x86_64-w64-mingw32.sh # CLONE_ON_CHINA会换用国内的源，再用国外的源更新上游
```
可以用[helloworld.cpp](../../../script/helloworld.cpp)测试一下编译器是否正常工作
```shell
# 因为生成了新的编译器，所以我们要重新导出工具链环境变量
get_toolchains
x86_64-w64-mingw32-g++ -o helloworld.exe helloworld.cpp -std=c++26
```
将生成的helloworld.exe在windows上运行
```shell
./helloworld.exe # hello world!
```
测试刚刚编译给Windows的加拿大本地编译器，先将压缩包传到Windows上，解压后运行
```shell
cp $TOOLCHIANSPATH/x86_64-w64-mingw32/x86_64-w64-mingw32.tar.gz /mnt/c/...
# 之后仿照刚刚步骤测试一下
```
### 构建x86-arm的 交叉编译器 与 加拿大本地编译器 与 加拿大交叉编译器
将会构建：  
* x86_64-pc-linux-gnu -> x86_64-pc-linux-gnu -> aarch64-linux-gnu 的x86交叉arm的交叉编译器
* x86_64-pc-linux-gnu -> aarch64-linux-gnu -> aarch64-linux-gnu 的加拿大本地编译器
* x86_64-pc-linux-gnu -> x86_64-w64-mingw32 -> aarch64-linux-gnu 的加拿大交叉编译器
```shell
cd $TOOLCHAINS_BUILD/toolchainbuildscripts/gccbuild/x86_64-w64-mingw32/
# 该脚本会克隆最新版linux源码，如果国外克隆慢的话可以直接在清华源克隆至$TOOLCHIANS_BUILD下，再运行该脚本
./aarch-linux-gnu.sh
```
验证环境略