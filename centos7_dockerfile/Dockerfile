FROM centos:7.8.2003

ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8

WORKDIR /root
COPY init.sh /root/init.sh

# Install tools
RUN bash init.sh
#    yum update -y && \
#    yum reinstall -y glibc-common && \
#    yum install -y  net-tools && \
#    yum clean all && \
#    rm -rf /tmp/* rm -rf /var/cache/yum/* && \
#    localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 && \
#    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Define default command.
# CMD ["bash"]
