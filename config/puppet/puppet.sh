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
else
  echo "Erro aplicando puppet"
fi

echo "Abrindo shell..."
bash
