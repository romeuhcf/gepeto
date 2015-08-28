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

echo 'validando presença de arquivo RPM'
ls /rpminstall/

echo "-----------------------------------------------------------------------------"
echo "- instalando rpm $RPM_TO_INSTALL"
echo "-----------------------------------------------------------------------------"
echo yum install -y "$RPM_TO_INSTALL"
yum install -y "$RPM_TO_INSTALL"
echo "-----------------------------------------------------------------------------"
echo "- abrindo shell..."
echo "-----------------------------------------------------------------------------"

bash