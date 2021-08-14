#!/bin/bash
set -x
# 环境变量
export LS_OPTIONS='--color=auto'                       # 如果没有指定，则自动选择颜色
export CLICOLOR='Yes'                                  #是否输出颜色
export LSCOLORS='CxfxcxdxbxegedabagGxGx'               #指定颜色
# 别名
alias ll='ls $LS_OPTIONS -l'

# 为了更好的编辑文件可以安装工具
yum update -y
yum install -y epel-release
yum install -y vim wget tree psmisc net-tools lsof
yum clean all
rm -rf /var/cache/yum/*

# python 工具
yum install -y python-devel python3

# go 工具
yum install -y go
go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct


yum reinstall -y glibc-common
localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime


## 安装编译 C 的环境
#yum install -y gcc gcc-c++
#yum install -y zlib
#yum install -y zlib-devel
#yum install -y tcl  build-essential tk gettext

# ssh
yum -y install passwd openssl openssh-server  openssh-clients
sed -i "s/#PermitEmptyPasswords no/PermitEmptyPasswords yes/g" /etc/ssh/sshd_config
sed -i "s/#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config
echo root:123456 | chpasswd
