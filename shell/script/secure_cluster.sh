#!/bin/bash

# resolve links - $0 may be a softlink
this="${BASH_SOURCE-$0}"
common_bin=$(cd -P -- "$(dirname -- "$this")" && pwd -P)
script="$(basename -- "$this")"
this="$common_bin/$script"

# convert relative path to absolute path
config_bin=`dirname "$this"`
script=`basename "$this"`
config_bin=`cd "$config_bin"; pwd`
this="$config_bin/$script"

NODES_FILE=$config_bin/../conf/nodes

if [ ! -f $NODES_FILE ]; then
    echo "ERROR: Can not found role configuration file $NODES_FILE"
	exit 1
fi

NODES=`cat $NODES_FILE`


role=$1
command=$2
dir=$role

if [ X"$role" == X"hdfs" ];then
  dir=hadoop
fi

if [ X"$role" == X"yarn" ];then
        dir=hadoop
fi

if [ X"$role" == X"mapred" ];then
        dir=hadoop
fi

for node in $NODES ;do
  echo "========$node========"
  ssh $node '
    echo root|kinit root/admin
    host=`hostname -f`
    path="'$role'/$host"
    #echo $path
    principal=`klist -k /etc/'$dir'/conf/'$role'.keytab | grep $path | head -n1 | cut -d " " -f5`
    #echo $principal
    if [ X"$principal" == X ]; then
      principal=`klist -k /etc/'$dir'/conf/'$role'.keytab | grep $path | head -n1 | cut -d " " -f4`
      if [ X"$principal" == X ]; then
            echo "Failed to get hdfs Kerberos principal"
            exit 1
      fi
      fi
      kinit -r 24l -kt /etc/'$dir'/conf/'$role'.keytab $principal
      if [ $? -ne 0 ]; then
          echo "Failed to login as hdfs by kinit command"
          exit 1
      fi
    kinit -R
    for src in `ls /etc/init.d|grep '$role'`;do service $src '$command'; done
  '
done
