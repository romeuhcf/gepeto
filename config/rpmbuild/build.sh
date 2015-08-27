#!/bin/bash 
set -e

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
mv /root/rpmbuild/SOURCES/code/*.bz2 /container_path
mv /root/rpmbuild/RPMS/*/*.rpm /container_path
