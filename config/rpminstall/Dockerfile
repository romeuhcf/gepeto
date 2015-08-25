FROM centos:centos6.6
RUN sed 's/.*keepcache.*/keepcache=1/' -i /etc/yum.conf
RUN yum install -y epel-release
ADD extra_repo.repo /etc/yum.repos.d/
ADD entrypoint.sh /root/
CMD bash /root/entrypoint.sh
