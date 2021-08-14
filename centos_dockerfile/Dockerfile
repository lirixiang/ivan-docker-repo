FROM centos:7.8.2003
MAINTAINER 565539277@qq.com

WORKDIR /root
ADD init.sh /tmp/init.sh

# Install tools
RUN /usr/bin/bash /tmp/init.sh

# Define default command.
CMD ["bash"]
