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
#  --name="yore_centos7"		为容器指定一个名称
#  -h "hostname"				    指定容器的hostname；
#  -m 	设置容器使用内存最大值；
#  --volume、-v					绑定一个卷
# --rm ：这个参数是说容器退出后随之将其删除。默认情况下，为了排障需 求，退出的容器并不会立即删除，除非手动 docker rm， 我们这里只是随便 执行个命令，看看结果，不需要排障和保留结果，因此使用 --rm 可以避免 浪费空间。
#  --privileged=false   指定容器是否为特权容器，特权容器拥有所有的capabilities
#  --cap-add=[]， 			添加权限，权限清单详见：http://linux.die.net/man/7/capabilities
docker run --privileged=true --cap-add SYS_ADMIN -e container=docker -it \
-p 30022:22 -p 30080:80  -h "bigdata" \
--name="centos7_base" -d yore/centos7_v1:latest /usr/sbin/init

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
# 1 为了更好的编辑文件可以安装 vim
yum install -y vim

# 2 为了查看端口信息更方便可以安装 lsof
yum install -y lsof

# 3 安装 wget
yum install -y wget

# 4 安装 tree
yum install -y tree

# 5 python 工具
yum install -y python-devel

# 6 安装编译 C 的环境
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
vim /etc/ssh/sshd_config
##  大概在  38 - 45 行之间，修改或添加如下三个配置
PermitRootLogin yes
RSAAuthentication yes
PubkeyAuthentication yes 
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 3 sshd 服务的启停
## 3.1 启动
systemctl start sshd.service
##  3.2 查看 sshd 服务状态
systemctl status sshd
## 3.3 停止
systemctl start sshd.service

# 4 设置为开机自启
systemctl enable sshd.service

# 【可跳过】5 生成ssh的密钥和公钥
# ssh-keygen -t rsa

# 6 查看 SSH 服务
lsof -i:22

# 7 设置 root 密码（2020）
passwd

# 8 通过 ssh 访问容器
ssh root@bigdata

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
将开发中常用到的环境进行安装和配置
# 1 运行。下面会对本容器做进一步的修改设置
# 以 base 镜像为准，启动容器
docker run --privileged=true --cap-add SYS_ADMIN -e container=docker -it \
-p 30022:22 -p 30080:80  -h "bigdata01" \
--name="centos7_dev1" -d centos7_base:v1 /usr/sbin/init

# 2 进入容器
docker ps
docker exec -it $CONTAINER_ID /bin/bash

# 3 hosts 改为。
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

# 6 查看Java版本
java -version
4.2 Git
# 1 下载源码方式，
wget -O git-2.27.0.tar.gz https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.27.0.tar.gz

# 2 解压
tar -zxf git-2.27.0.tar.gz -C /tmp/
cd /tmp/git-2.27.0 

# 3 检验相关依赖，设置安装路径
./configure --prefix=/usr/local/git

# 4 安装
make && make install

# 5 创建软连接
ln -s /usr/local/git/bin/git /usr/bin/git

# 6 查看版本
git -v
4.3 Maven
# 1 下载
wget https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz

# 2 解压
tar -zxf apache-maven-3.6.3-bin.tar.gz
mv apache-maven-3.6.3 /usr/local/maven3

# 3 修改配置
vim /usr/local/maven3/conf/settings.xml
配置如下内容

<!--大概在 55 行左右添加，指定本地仓库的路径-->
 <localRepository>/opt/.m2/repo</localRepository>

 <!--大概在158 行左右，配置国内镜像，这里配置为阿里 Maven 镜像-->
<!-- 配置阿里云的镜像 -->
<mirror>
      <id>nexus-aliyun</id>
      <mirrorOf>*</mirrorOf>
      <name>Nexus aliyun</name>
      <url>http://maven.aliyun.com/nexus/content/groups/public</url>
</mirror>

<mirror>
  <id>central-repos1</id>
  <name>Central Repository 2</name>
  <url>https://repo1.maven.org/maven2/</url>
      <!-- 表示只为central仓库做镜像，如果想为所有的仓库做镜像那么可以改为 -->
  <mirrorOf>*</mirrorOf>
</mirror>

继续完成下面的配置

# 4 配置环境变量，
vim /etc/profile
# set Maven environment
export MAVEN_HOME=/usr/local/maven3
export PATH=$PATH:$MAVEN_HOME/bin

# 5 生效
source /etc/profile

# 6 查看版本
mvn -version

4.4 Nginx
# 1 下载 Nginx 离线安装包。以 x86、centos7版本为例
wget http://nginx.org/packages/mainline/centos/7/x86_64/RPMS/nginx-1.17.6-1.el7.ngx.x86_64.rpm

# 2 安装
rpm -ivh nginx-1.17.6-1.el7.ngx.x86_64.rpm

# 3 配置文件
/etc/nginx
# server 服务可以配置到下面路径，以 .conf 结尾，重启或使配置生效
/etc/nginx/conf.d/

# 4 常用命令
## 4.1 启动，应为已经将内部 80端口映射到了宿主机的 30080，所以通过宿主机 ip 和 30080 端口浏览器访问
systemctl start nginx
## 4.2 状态
systemctl status nginx
## 4.3 停止
systemctl stop nginx
## 4.4 重启
systemctl restart nginx
## 4.5 配置重新生效
/usr/sbin/nginx -s reload

# 这里提供的镜像已停止了 Nginx 服务，在需要时请手动启动
4.5 Node.js
# 1 下载
wget https://nodejs.org/dist/v12.18.2/node-v12.18.2-linux-x64.tar.xz

# 2 解压
tar -xf node-v12.18.2-linux-x64.tar.xz
mv node-v12.18.2-linux-x64 /usr/local/nodejs

# 3 创建连接
ln -s /usr/local/nodejs/bin/node /usr/bin/node
ln -s /usr/local/nodejs/bin/npm /usr/bin/npm

# 4 查看版本
node -v
npm -v
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