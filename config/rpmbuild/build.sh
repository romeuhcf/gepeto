#!/bin/bash
set -e

echo "Adicionando repositoris extra: $EXTRA_REPOS"
for repo in $EXTRA_REPOS
do
  echo "[$repo]
name=$repo repository
baseurl=http://packages.abril.com.br/$repo-prod/latest/x86_64/
enabled=1
gpgcheck=0

"
done > /etc/yum.repos.d/abril.repo

# prepare stuff
cp -rf /code /root/rpmbuild/SOURCES/
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
ls /root/rpmbuild/RPMS/*/*.rpm
echo cp -fv /root/rpmbuild/RPMS/*/*.rpm /container_path
cp -fv /root/rpmbuild/RPMS/*/*.rpm /container_path
