#!/bin/sh

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


NN_FILE=$config_bin/../conf/namenode
DN_FILE=$config_bin/../conf/datanode
NN=`cat $NN_FILE |tr '\n' ','|  sed 's/,$//'`
ZK_HOSTNAME=`cat $DN_FILE |tr '\n' ','|  sed 's/,$//'`

echo "[INFO]:copy hadoop template conf"

\cp $config_bin/../template/impala /etc/default/impala
for srv in hadoop hbase hive zookeeper ; do
	\cp $config_bin/../template/${srv}/* /etc/${srv}/conf/
done

chmod 755 /etc/hadoop/conf/*.sh

echo "[INFO]:replace hadoop conf"
sed -i "s|localhost|$NN|g" /etc/hadoop/conf/core-site.xml
sed -i "s|localhost|$NN|g" /etc/hadoop/conf/hdfs-site.xml
sed -i "s|localhost|$NN|g" /etc/hadoop/conf/mapred-site.xml
sed -i "s|localhost|$NN|g" /etc/hadoop/conf/yarn-site.xml
sed -i "s|localhost|$NN|g" /etc/hive/conf/hive-site.xml
sed -i "s|localhost|$NN|g" /etc/hbase/conf/hbase-site.xml
sed -i "s|localhost|$NN|g" /etc/default/impala
sed -i "s|zkhost|$ZK_HOSTNAME|g" /etc/hbase/conf/hbase-site.xml

sh $config_bin/../script/syn.sh /etc/hadoop/conf /etc/hadoop
sh $config_bin/../script/syn.sh /etc/hive/conf /etc/hive
sh $config_bin/../script/syn.sh /etc/hbase/conf /etc/hbase
sh $config_bin/../script/syn.sh /etc/zookeeper/conf /etc/zookeeper
