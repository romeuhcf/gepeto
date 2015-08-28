#!/bin/bash
set -e

for repo in $EXTRA_REPOS
do
  echo "[$repo]
name=$repo repository
baseurl=http://packages.abril.com.br/$repo-prod/latest/x86_64/
enabled=1
gpgcheck=0

"
done > /etc/yum.repos.d/abril.repo

echo "Extra Repos"
cat /etc/yum.repos.d/abril.repo

# prepare stuff
cd /root/rpmbuild/SOURCES/code
make sources
cp *.spec /root/rpmbuild/SPECS
cp -v *.bz2 /root/rpmbuild/SOURCES
# generate rpm
cd /root/rpmbuild/SPECS
yum-builddep -y *.spec
echo "-------------------------------------------------------------------------------"
echo RPMBUILD
echo "-------------------------------------------------------------------------------"
rpmbuild -ba *.spec
echo "-------------------------------------------------------------------------------"
cp /root/rpmbuild/RPMS/*/*.rpm /root/rpmbuild/SOURCES/code #/dist