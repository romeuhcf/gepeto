FROM centos:centos6.6
RUN sed 's/.*keepcache.*/keepcache=1/' -i /etc/yum.conf
RUN rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm 
RUN yum install -y puppet epel-release
RUN yum update krb5-libs libcom_err openssl -y 
ADD puppet.sh /root/
CMD bash /root/puppet.sh
