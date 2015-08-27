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
cp /root/rpmbuild/RPMS/*/*.rpm /root/rpmbuild/SOURCES/code #/dist