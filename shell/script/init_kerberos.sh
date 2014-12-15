#!/bin/bash

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

NODES_FILE=$PROGDIR/../conf/nodes

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
