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


DNS=JAVACHEN.COM

for host in  $NODES ;do
  for user in hdfs HTTP yarn mapred hive impala sentry zookeeper zkcli; do
    kadmin.local -q "addprinc -randkey $user/$host@$DNS"
    kadmin.local -q "xst -k /var/kerberos/krb5kdc/$user-unmerged.keytab $user/$host@$DNS"
  done
done
