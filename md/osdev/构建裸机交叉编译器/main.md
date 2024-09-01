# 构建裸机交叉编译器

## 准备工作
在开始之前，您需要完成：  
* [01构建gcc本地编译器](../../cqwrteur课程/01构建gcc本地编译器/main.md)

您可以参考：  
* [GCC 交叉编译器](https://wiki.osdev.org/GCC_Cross-Compiler)

## 为x86_64-elf构建构建交叉编译器
### 构建binutils-gdb
跟本地编译一样，注意指定一下生成目标
```shell
mkdir -p $TOOLCHIANS_BUILD/build/x86_64-pc-linux-gnu/x86_64-elf/binutils-gdb
mkdir -p $TOOLCHAINSPATH/x86_64-pc-linux-gnu/x86_64-elf

cd $TOOLCHAINS_BUILD/build/x86_64-pc-linux-gnu/x86_64-elf/binutils-gdb
$TOOLCHIANS_BUILD/binutils-gdb/configure \
	--prefix=$TOOLCHAINSPATH/x86_64-pc-linux-gnu/x86_64-elf \
	--target=x86_64-elf \ # 注意要指定生成目标
	--disable-nls \  # 取消本地语言支持，加快编译速度
	--disable-werror \
	--enable-gold \
	# --with-python3 \ 
make -j$(nproc)
make install-strip -j
```
别忘了加环境变量
```shell
get_toolchains
```
验证一下
```shell
x86_64-elf-gdb --version
# GNU gdb (GDB) 16.0.50.20240828-git
# Copyright (C) 2024 Free Software Foundation, Inc.
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.
x86_64-elf-ar --version
# GNU ar (GNU Binutils) 2.43.50.20240828
# Copyright (C) 2024 Free Software Foundation, Inc.
# This program is free software; you may redistribute it under the terms of
# the GNU General Public License version 3 or (at your option) any later version.
# This program has absolutely no warranty.
x86_64-elf-objdump --version
# GNU objdump (GNU Binutils) 2.43.50.20240828
# Copyright (C) 2024 Free Software Foundation, Inc.
# This program is free software; you may redistribute it under the terms of
# the GNU General Public License version 3 or (at your option) any later version.
# This program has absolutely no warranty.
```
### 构建交叉编译器 
跟本地编译一样，注意指定生成目标
> 注意，这里要关注一个红区(red-zone)的问题，可以参考[osdev](https://wiki.osdev.org/Libgcc_without_red_zone)
```shell
mkdir -p $TOOLCHIANS_BUILD/build/x86_64-pc-linux-gnu/x86_64-elf/gcc
mkdir -p $TOOLCHAINSPATH/x86_64-pc-linux-gnu/x86_64-elf

cd $TOOLCHIANS_BUILD/build/x86_64-pc-linux-gnu/x86_64-elf/gcc
$TOOLCHAINS_BUILD/gcc/configure \
	--prefix=$TOOLCHAINSPATH/x86_64-pc-linux-gnu/x86_64-elf \
	--target=x86_64-elf \ # 注意要指定生成目标
	--disable-nls \  # 取消本地语言支持，加快编译速度
	--disable-werror \
	--disable-bootstrap \
	--enable-languages=c,c++ \
	--disable-libstdcxx-verbose \
	--without-headers \ # 不要依赖生成目标的任何c库
	--disable-hosted-libstdcxx \ # 不要依赖生成目标的任何宿主c++库
	--disable-libssp \
	--disable-libquadmath \
	--disable-libbacktrace \
	--disable-shared \
	--disable-threads \
	--with-libstdcxx-en-pool-obj-count=0 \
	--disable-sjij-exceptions
	# --disable-multilib

make all-gcc -j$(nproc)
make all-target-libgcc -j$(nproc)
make install-gcc -j
make install-target-libgcc -j
```
我们没有运行make，而是更细分的添加了一些选项  
一是因为我们不需要构建那么多东西，二是因为我们**取消了c库依赖，会导致有些库编译错误**  

验证一下
```shell
x86_64-elf-g++ -v
# Using built-in specs.
# COLLECT_GCC=x86_64-elf-g++
# COLLECT_LTO_WRAPPER=/home/nagisa/toolchains/x86_64-pc-linux-gnu/x86_64-elf/libexec/gcc/x86_64-elf/15.0.0/lto-wrapper
# Target: x86_64-elf
# Configured with: /home/nagisa/toolchains_build/gcc/configure --prefix=/home/nagisa/toolchains/x86_64-pc-linux-gnu/x86_64-elf --target=x86_64-elf --disable-nls --disable-werror --disable-bootstrap --enable-languages=c,c++ --disable-multilib --disable-libstdcxx-verbose --without-headers
# Thread model: single
# Supported LTO compression algorithms: zlib zstd
# gcc version 15.0.0 20240828 (experimental) (GCC)
```
成功！