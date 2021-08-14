Dockerfile 可以基于一个已有的镜像,添加一些配置或部署一下程序后 构建成为一个新的对象。 常用的命令。
```shell
FROM image_name:tag  定义使用哪个基本镜像启动构建流程
MAINTAINER user_name  声明镜像的创建者。版权声明
ENV key value  添加环境变量 这个可以写多个
RUN command  表示要执行的命令 这个是核心内容 可以写多条
ADD source_dir/file dest_dir/file  将宿主机的文件复制到容器中 如果是压缩文件的话 会自己解压
COYP source_dir/file dest_dir/file  同ADD 就是不会解压
WORKDIR path_dir  工作目录 就是这样命令执行的目录 登录容器后也在这个目录
CMD 容器启动后要处理的命令
```
