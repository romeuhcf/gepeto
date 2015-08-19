FROM centos:centos6
RUN yum install -y rpm-build rpmdevtools git yum-utils tar gcc gcc-c++ epel-release
RUN echo -ne "packager docker-builder\n%_topdir /root/rpmbuild\n%_tmppath /root/rpm/tmp"
ADD config/dockerfiles/extra_repo.repo /etc/yum.repos.d/
RUN yum install -y gcc gcc-c++ ruby22 rubygem22-bundler libxml2 libxml2-devel libxslt libxslt-devel liboboe-devel sqlite-devel mysql-devel ruby22 rubygem22-bundler libxml2 libxslt httpd nodejs
ADD config/dockerfiles/build.sh /root/
RUN mkdir -p /root/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS,tmp}
CMD bash /root/build.sh


