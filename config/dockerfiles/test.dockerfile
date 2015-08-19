FROM centos:centos6 
RUN yum install -y epel-release
# ABRIL RUBY
ADD config/dockerfiles/extra_repo.repo /etc/yum.repos.d/
RUN yum install -y ruby22 rubygem22-rack rubygem22-bundler libyaml libxml2 libxslt rubygems22-rake
# RUBY DEV
RUN yum install -y libxml2-devel libxslt-devel libyaml-devel gcc gcc-c++
# RUBY ASSETS
RUN yum install -y nodejs

RUN mkdir /root/code

# to install redis from REMI 2.8
RUN curl http://rpms.famillecollet.com/enterprise/remi-release-6.rpm > /tmp/remi-release-6.rpm && rpm -Uvh /tmp/remi-release-6.rpm && sed 's/enabled.*/enabled=1/g' -i /etc/yum.repos.d/remi.repo
RUN yum install -y redis

ENV HOME /root/code
ENV PATH /opt/ruby-2.2.2/bin:$PATH 

CMD redis-server --port 6379 & cd /root/code; bundle install --retry=3 --jobs=6; bundle exec rake spec
