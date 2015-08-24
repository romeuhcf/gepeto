FROM centos:centos6.6
RUN rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm 
RUN yum install -y puppet epel-release

#ADD tmp/extra_repo.repo /etc/yum.repos.d/
ADD puppet.sh /root/
RUN yum install -y epel-release
CMD bash /root/puppet.sh
