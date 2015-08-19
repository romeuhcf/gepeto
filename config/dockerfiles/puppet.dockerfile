FROM centos:centos6
#RUN yum install -y rpm-build rpmdevtools git yum-utils tar gcc gcc-c++ epel-release
RUN rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm 
RUN yum install -y puppet

ADD config/dockerfiles/extra_repo.repo /etc/yum.repos.d/
ADD config/dockerfiles/puppet.sh /root/
CMD bash /root/puppet.sh


