#!/bin/bash 
set -e 

if [ -z "$PUPPET_MODULE" ]; then 
  echo "Favor setar a variavel de ambiente PUPPET_MODULE"
  exit 1
fi 

facter 
PUPPET_ROOT="/etc/puppet"
cp "$PUPPET_ROOT/hiera.yaml.sample" "$PUPPET_ROOT/hiera.yaml"
MODULES_PATH="$PUPPET_ROOT/modules"
puppet apply -tvd --modulepath=$MODULES_PATH -e"include $PUPPET_MODULE"

