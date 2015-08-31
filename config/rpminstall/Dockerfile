FROM centos:centos6.6
RUN sed 's/.*keepcache.*/keepcache=1/' -i /etc/yum.conf
RUN yum install -y epel-release
RUN yum update krb5-libs libcom_err openssl -y 
ADD entrypoint.sh /root/
CMD bash /root/entrypoint.sh
