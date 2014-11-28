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

PASSWORD="redhat"
HOSTNAME=`hostname -f`
NODES_FILE=$config_bin/../conf/nodes
NODES="`cat $NODES_FILE |sort -n | uniq | tr '\n' ' '|  sed 's/,$//'`"

#设置无密码登陆
echo -e "[INFO]:Config `hostname -f`'s ssh"
[ ! -d ~/.ssh ] && ( mkdir ~/.ssh ) && ( chmod 600 ~/.ssh )
[ ! -f ~/.ssh/id_rsa.pub ] && (yes|ssh-keygen -f ~/.ssh/id_rsa -t rsa -N "") && ( chmod 600 ~/.ssh/id_rsa.pub )

yum install -y jdk hadoop hbase hive zookeeper hadoop-yarn impala rsync expect ntp pssh
if ! rpm -q jdk hadoop hbase hive zookeeper hadoop-yarn impala rsync expect ntp pssh>/dev/null ; then
    echo "[ERROR]:Missing libs: jdk hadoop hbase hive zookeeper hadoop-yarn impala rsync expect ntp pssh"
		exit 1
fi

echo "[INFO]:Config ssh nopassword"
for node in $NODES ;do
	$config_bin/ssh_nopassword.expect $node $PASSWORD >/dev/null
done

pscp -H "$NODES" /etc/yum.repos.d/*.repo /etc/yum.repos.d/
pssh -P -i -H "$NODES"  "`cat $config_bin/config_system.sh`"

$config_bin/config_ntp.sh
