FROM centos:centos6.6
RUN sed 's/.*keepcache.*/keepcache=1/' -i /etc/yum.conf
RUN yum install -y rpm-build rpmdevtools git yum-utils tar gcc gcc-c++ epel-release
RUN yum update krb5-libs libcom_err openssl -y 
RUN echo -ne "packager docker-builder\n%_topdir /root/rpmbuild\n%_tmppath /root/rpm/tmp"
RUN mkdir -p /root/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS,tmp}
ADD build.sh /root/
CMD bash /root/build.sh
