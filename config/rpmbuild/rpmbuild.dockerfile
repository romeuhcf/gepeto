FROM centos:centos6.6
RUN yum install -y rpm-build rpmdevtools git yum-utils tar gcc gcc-c++ epel-release
RUN echo -ne "packager docker-builder\n%_topdir /root/rpmbuild\n%_tmppath /root/rpm/tmp" 
ADD tmp/extra_repo.repo /etc/yum.repos.d/
ADD tmp/build.sh /root/
RUN mkdir -p /root/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS,tmp}
RUN sed 's/.*keepcache.*/keepcache=1/' -i /etc/yum.conf
CMD bash /root/build.sh


