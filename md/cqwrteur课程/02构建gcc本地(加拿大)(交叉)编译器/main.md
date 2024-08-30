# ����gcc ���ؽ�������������ô󱾵ر����������ô󽻲������
��ʼ���̳�֮ǰ������Ҫ��  
* �Ķ�[�����ա��������Ĺ�������ԭ��](https://zhuanlan.zhihu.com/p/553543765)  
* ���[ ����gcc���ر�����](../01����gcc���ر�����/main.md)

## ����gcc
������������������
```shell
get_toolchians
```
��������
```shell
# ubuntu
sudo apt install gettext rsync mercurial
# arch linux
sudo pacman -S gettext rsync mercurial
```
��¡glibc
```shell
# ����汾�������Ŀ��ƽ̨�����������ҵĿ������ϵ�glibc�汾��2.35�������Ҿ���2.35�汾
cd $TOOLCHAINS_BUILD
git clone -b release/2.35/master git://sourceware.org/git/glibc.git
```
��¡[cqwrteur�Ĺ����ű�](https://github.com/trcrsired/toolchainbuildscripts)
```shell
cd $TOOLCHIANS_BUILD
git clone https://github.com/trcrsired/toolchainbuildscripts.git
```
### ����linux-windows�Ľ������������ô󱾵ر�����
���ṹ��:  
* x86_64-pc-linux-gnu -> x86_64-pc-linux-gnu -> x86_64-w64-mingw32 ��linux����windows�Ľ��������
* x86_64-pc-linux-gnu -> x86_64-w64-mingw32 -> x86_64-w64-mingw32 �ļ��ô󱾵ر�����
```shell
cd $TOOLCHAINS_BUILD/toolchainbuildscripts/gccbuild/x86_64-w64-mingw32/
CLONE_ON_CHINA=yes ./x86_64-w64-mingw32.sh # CLONE_ON_CHINA�ỻ�ù��ڵ�Դ�����ù����Դ��������
```
������[helloworld.cpp](../../../script/helloworld.cpp)����һ�±������Ƿ���������
```shell
# ��Ϊ�������µı���������������Ҫ���µ�����������������
get_toolchains
x86_64-w64-mingw32-g++ -o helloworld.exe helloworld.cpp -std=c++26
```
�����ɵ�helloworld.exe��windows������
```shell
./helloworld.exe # hello world!
```
���Ըոձ����Windows�ļ��ô󱾵ر��������Ƚ�ѹ��������Windows�ϣ���ѹ������
```shell
cp $TOOLCHIANSPATH/x86_64-w64-mingw32/x86_64-w64-mingw32.tar.gz /mnt/c/...
# ֮����ոող������һ��
```
### ����x86-arm�� ��������� �� ���ô󱾵ر����� �� ���ô󽻲������
���ṹ����  
* x86_64-pc-linux-gnu -> x86_64-pc-linux-gnu -> aarch64-linux-gnu ��x86����arm�Ľ��������
* x86_64-pc-linux-gnu -> aarch64-linux-gnu -> aarch64-linux-gnu �ļ��ô󱾵ر�����
* x86_64-pc-linux-gnu -> x86_64-w64-mingw32 -> aarch64-linux-gnu �ļ��ô󽻲������
```shell
cd $TOOLCHAINS_BUILD/toolchainbuildscripts/gccbuild/x86_64-w64-mingw32/
# �ýű����¡���°�linuxԴ�룬��������¡���Ļ�����ֱ�����廪Դ��¡��$TOOLCHIANS_BUILD�£������иýű�
./aarch-linux-gnu.sh
```
��֤������