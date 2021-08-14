
# 1 为了更好的编辑文件可以安装 vim
yum install -y vim
#
## 2 为了查看端口信息更方便可以安装 lsof
#yum install -y lsof
#
## 3 安装 wget
#yum install -y wget
#
## 4 安装 tree
#yum install -y tree
#
## 5 python 工具
#yum install -y python-devel
#
## 6 安装编译 C 的环境
#yum install -y gcc gcc-c++
#yum install -y zlib
#yum install -y zlib-devel
#yum install -y tcl  build-essential tk gettext

# ssh
#yum -y install passwd openssl openssh-server  openssh-clients
#mkdir  /var/run/sshd/

# 2 修改配置
#vim /etc/ssh/sshd_config
#sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
