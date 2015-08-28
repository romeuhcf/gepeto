FROM centos:centos6.6
RUN sed 's/.*keepcache.*/keepcache=1/' -i /etc/yum.conf
RUN yum install -y epel-release
ADD entrypoint.sh /root/
CMD bash /root/entrypoint.sh