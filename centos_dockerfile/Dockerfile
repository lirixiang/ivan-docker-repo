FROM centos:7.8.2003

ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8 \
    PS1='[\u@\h \# \w]\$'

MAINTAINER 565539277@qq.com

WORKDIR /root
ADD init.sh /tmp/init.sh

# Install tools
RUN /usr/bin/bash /tmp/init.sh

# Define default command.
CMD ["bash"]
