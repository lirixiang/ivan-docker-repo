#!/bin/bash
set -x
cat  >> /root/.bashrc << EOF
# env
export PS1='[\u@\h \# \w]\$'
export LANG=en_US.utf8

# alias
alias l.='ls -d .* --color=tty'
alias ll='ls -l --color=tty'
alias ls='ls --color=tty'
alias vi='vim'
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
alias ...=../..
alias ....=../../..
alias .....=../../../..
alias ......=../../../../..
EOF
source /root/.bashrc

# 为了更好的编辑文件可以安装工具
yum update -y
yum install -y epel-release
yum install -y vim wget  psmisc net-tools lsof
yum clean all
rm -rf /var/cache/yum/*

# python 工具
# yum install -y python-devel python3

# go 工具
yum install -y go
go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct

## 安装编译 C 的环境
#yum install -y gcc gcc-c++
#yum install -y zlib
#yum install -y zlib-devel
#yum install -y tcl  build-essential tk gettext

# ssh
yum -y install  openssl openssh-server  openssh-clients
sed -i "s/#PermitEmptyPasswords no/PermitEmptyPasswords yes/g" /etc/ssh/sshd_config
sed -i "s/#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config
echo root:123456 | chpasswd
