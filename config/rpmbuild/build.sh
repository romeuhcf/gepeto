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
echo
echo
echo
echo "-------------------------------------------------------------------------------"
echo REMOTE: $(git remote -v | grep fetch)
echo BRANCH: $(git checkout master; git branch)
echo INFO:   $(make info)
echo TAGS:   $(git describe --abbrev=0 --tags)
echo "-------------------------------------------------------------------------------"
echo
echo
echo
echo "-------------------------------------------------------------------------------"
echo "Making sources"
echo "-------------------------------------------------------------------------------"
make sources 
cp *.spec /root/rpmbuild/SPECS
cp -v *.bz2 /root/rpmbuild/SOURCES
echo "-------------------------------------------------------------------------------"
echo
echo
echo
echo "-------------------------------------------------------------------------------"
echo "Installing build dependencies"
echo "-------------------------------------------------------------------------------"
cd /root/rpmbuild/SPECS
yum-builddep -y *.spec
echo "-------------------------------------------------------------------------------"
echo
echo
echo
echo "-------------------------------------------------------------------------------"
echo Generating package with rpmbuild 
echo "-------------------------------------------------------------------------------"
rpmbuild -ba *.spec
echo "-------------------------------------------------------------------------------"
echo
echo
echo
echo "-------------------------------------------------------------------------------"
echo Making RPM available
echo "-------------------------------------------------------------------------------"
cp -fv /root/rpmbuild/RPMS/*/*.rpm /container_path
echo "-------------------------------------------------------------------------------"
