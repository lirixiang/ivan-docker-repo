#!/bin/bash
set -x
cat  >> /root/.bashrc << EOF
export PS1='[\u@\h \# \w]\$'
export LANG=en_US.utf8
EOF
source /root/.bashrc

# 为了更好的编辑文件可以安装工具
yum update -y
yum install -y epel-release
yum clean all
rm -rf /var/cache/yum/*


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
