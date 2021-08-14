[toc]
将下面配置内容放到环境中的某个目录下 的Dockerfile 文件中，执行构建命令 
```bash
docker build -t centos-dev .
``` 
启动容器
```shell
# 1 运行。下面会对本容器做进一步的修改设置
#  -d 	后台运行容器
#  -p  	指定端口映射，格式为：主机(宿主)端口:容器端口
#  --name="centos-dev"		为容器指定一个名称
#  -h "hostname"				    指定容器的hostname；
#  -m 	设置容器使用内存最大值；
#  --volume、-v					绑定一个卷
# --rm ：这个参数是说容器退出后随之将其删除。默认情况下，为了排障需 求，退出的容器并不会立即删除，除非手动 docker rm， 我们这里只是随便 执行个命令，看看结果，不需要排障和保留结果，因此使用 --rm 可以避免 浪费空间。
#  --privileged=false   指定容器是否为特权容器，特权容器拥有所有的capabilities
#  --cap-add=[]， 			添加权限，权限清单详见：http://linux.die.net/man/7/capabilities
docker run --privileged=true --cap-add SYS_ADMIN -e container=docker -it \
-p 30022:22 -p 30080:80  -h "docker-test" \
-v ~/Desktop:/root/Desktop \
--name="centos-dev" -d centos-dev:latest /usr/sbin/init

# 2 启停容器
## 2.1 关闭容器
docker stop $CONTAINER_ID
## 2.2 启动某个容器
docker start $CONTAINER_ID
## 2.3 移除容器
docker rm -f $CONTAINER_ID

# 3 删除镜像
## image rm 等价于 rmi
docker image rm $IMAGE_ID
## 如果有多个相同的 IMAGE ID 的删除
docker rmi $REPOSITORY:$TAG

# 4 进入容器
docker exec -it $CONTAINER_ID /bin/bash
## 查看当前容器中 Centos7 版本
cat /etc/redhat-release
```
在容器中安装配置一些基础服务
```shell
yum install -y vim wget tree psmisc net-tools lsof

#  安装编译 C 的环境
yum install -y gcc gcc-c++
yum install -y zlib
yum install -y zlib-devel
yum install -y tcl  build-essential tk gettext
```
SSH
```shell
# 1 yum 安装 spenssl 服务
yum -y install passwd openssl openssh-server  openssh-clients
mkdir  /var/run/sshd/

# 2 修改配置
yum -y install passwd openssl openssh-server  openssh-clients
sed -i "s/#PermitEmptyPasswords no/PermitEmptyPasswords yes/g" /etc/ssh/sshd_config
sed -i "s/#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config
echo root:123456 | chpasswd

#  sshd 服务的启停
#启动
systemctl start sshd.service
# 查看 sshd 服务状态
systemctl status sshd
# 停止
systemctl start sshd.service
# 设置为开机自启
systemctl enable sshd.service
```

镜像提交到阿里云镜像库
1. 登录阿里云Docker Registry
   $ docker login --username=131****5960 registry.cn-hangzhou.aliyuncs.com
   用于登录的用户名为阿里云账号全名，密码为开通服务时设置的密码。

您可以在访问凭证页面修改凭证密码。

2. 从Registry中拉取镜像
   $ docker pull registry.cn-hangzhou.aliyuncs.com/lirixiang/ivan:[镜像版本号]
3. 将镜像推送到Registry
   $ docker login --username=131****5960 registry.cn-hangzhou.aliyuncs.com
   $ docker tag [ImageId] registry.cn-hangzhou.aliyuncs.com/lirixiang/ivan:[镜像版本号]
   $ docker push registry.cn-hangzhou.aliyuncs.com/lirixiang/ivan:[镜像版本号]


保存为本地镜像
```shell
# 1 停止当前运行的容器
# docker stop $CONTAINER_ID

# 2 commit 该 docker 容器
docker commit $CONTAINER_ID dev_mysql:v1

# 3 查看当前的镜像库
docker images
```
开发环境版 Centos7 镜像
```shell

docker ps
docker exec -it $CONTAINER_ID /bin/bash

#  hosts 改为。
172.17.0.3   yore.node1 bigdata01

4.1 JDK
# 1 下载。如果下面链接失效，则需要登录Oracle的账号，
# 访问 https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html 下载 jdk8
wget https://download.oracle.com/otn/java/jdk/8u231-b11/5b13a193868b4bf28bcb45c792fce896/jdk-8u231-linux-x64.tar.gz?AuthParam=1573137213_adc79b33f2d9ed27cb8b09b6adf71820

# 2 解压
tar -zxf jdk-8u231-linux-x64.tar.gz -C /usr/local/
chown root:root -R /usr/local/jdk1.8.0_231

# 3 配置环境变量
vim /etc/profile
# 添加如下配置
### set java environment
JAVA_HOME=/usr/local/jdk1.8.0_231
JRE_HOME=$JAVA_HOME/jre
CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
export JAVA_HOME JRE_HOME CLASS_PATH PATH

# 4 并加载生效：
source /etc/profile

# 5 为了使每次进入容器时都生效
vim ~/.bashrc
# 最后一行添加，保存
source /etc/profile
```

带 MySQL 版Centos7镜像
```shell
这里在开发环境版的镜像基础上安装 MySQL 数据库
5.1 设置 Docker 网络
# 1 查看存在的网络（默认会创建三个）
#  bridge           桥接网络。每次Docker容器重启时，会按照顺序获取对应的IP地址，这个就导致重启后 IP 地址可能会改变
#  host             主机网络。Docker 容器的网络会附属在主机上，两者是互通的。
#  none             容器就不会分配局域网的IP
[yore@VM_0_3_centos app]$ sudo docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
ba8077c371b9        bridge              bridge              local
1be5b2b64e10        host                host                local
77ef163ae7c4        none                null                local

# 2 创建自定义的网络。
# sudo docker network prune
# 注意：不能和已有的网段冲突
sudo docker network create --subnet=172.19.0.0/16 mynetwork
5.2 启动容器
# 1 运行。下面会对本容器做进一步的修改设置
# 以 centos7_dev 镜像为准，启动容器
# network 网络方式指定为前面自定义的 mynetwork，这样我们可以直接指定 ip
docker run --privileged=true --cap-add SYS_ADMIN -e container=docker -it \
--network mynetwork --ip 172.19.0.2 -h "bigdata02" --name="dev_mysql_v1" \
-p 30022:22 -p 33306:3306 \
-d centos7_dev:v1 /usr/sbin/init

# 2 进入容器
docker ps
docker exec -it $CONTAINER_ID /bin/bash

# 3 【可选】hosts 改为。也可以在 run 时指定
172.19.0.2   yore.node2 bigdata02
5.3 MySQL
MySQL 安装详见我的 blog CDH 6.2.0 或 6.3.0 安装实战及官方文档资料链接#1.5 MySQL 内容。
• 系统中 mysql 用户的默认密码为 mysql。安全起见，在公网下请修改为密码强度更大的密码
• MySQL 默认开启了 binlog。可以在配置文件中关闭掉。
• 当报 error while loading shared libraries: libnuma.so.1: cannot open shared object file: No such file or directory，执行 yum -y install numactl.x86_64。
• MySQL 数据库管理员账号 root 的密码默认为 123456。可以自行修改为密码强度更大的密码。
• 默认情况下，远程连接：mysql -h 宿主机ip -P 33306 -uroot -p 。

```