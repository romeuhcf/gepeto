#!/bin/bash 
set -e 
mkdir -p /opt/lib/puppet
if [ -z "$PUPPET_MODULE" ]; then 
  echo "Favor setar a variavel de ambiente PUPPET_MODULE"
  exit 1
fi 

facter 
PUPPET_ROOT="/etc/puppet"
cp "$PUPPET_ROOT/hiera.yaml.sample" "$PUPPET_ROOT/hiera.yaml"
MODULES_PATH="$PUPPET_ROOT/modules"

if puppet apply -tvd --modulepath=$MODULES_PATH -e"include $PUPPET_MODULE"; then
  echo "Sucesso aplicando puppet"
  if [ -n "$RPM_TO_INSTALL_AFTER" ]; then
    echo
    echo "-----------------------------------------------------------------------------"
    echo "- instalando rpm $RPM_TO_INSTALL_AFTER"
    echo "-----------------------------------------------------------------------------"
    yum -Uvh "$RPM_TO_INSTALL_AFTER"
  fi
else
  echo "Erro aplicando puppet"
fi

echo 
echo "-----------------------------------------------------------------------------"
echo "Abrindo shell..."
echo "-----------------------------------------------------------------------------"
echo
echo "caso deseje rodar o puppet manualmente, usar o comando: "
echo "  puppet apply -tvd --modulepath=$MODULES_PATH -e'include $PUPPET_MODULE'"
echo
bash

