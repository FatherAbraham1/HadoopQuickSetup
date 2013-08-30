#!/bin/sh

NODES_FILE="/etc/edh/nodes.csv"
ZK_HOSTNAME="cdh-1,cdh-2,cdh-3,cdh-4,cdh-5,cdh-6,cdh-7"

SLAVES=`cat $NODES_FILE`

echo "Copy hadoop conf files to /etc/XXX/conf ..."

cp -u /etc/edh/conf-template/hadoop/conf/* /etc/hadoop/conf
cp -u /etc/edh/conf-template/hive/conf/* /etc/hive/conf
cp -u /etc/edh/conf-template/hbase/conf/* /etc/hbase/conf
cp -u /etc/edh/conf-template/zookeeper/conf/* /etc/zookeeper/conf

echo "Update hadoop conf files ..."
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/core-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/hdfs-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/mapred-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/yarn-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hive/conf/hive-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hbase/conf/hbase-site.xml
sed -i "s|zkhost|$ZK_HOSTNAME|g" /etc/hbase/conf/hbase-site.xml
sed -i "s|localhost|$SLAVES|g" /etc/hadoop/conf/slaves
sed -i "s|localhost|$SLAVES|g" /etc/hbase/conf/regionservers

pscp -h $NODES_FILE /etc/edh/postgresql-9.1-901.jdbc4.jar /usr/lib/hive/lib/postgresql-jdbc.jar

for node in `cat $NODES_FILE` ;do
	echo "[INFO]:Syn hadoop conf files to $node"
	rsync /etc/hadoop/conf.edh root@$node:/etc/hadoop -avz --delete
	rsync /etc/hive/conf.edh root@$node:/etc/hive -avz --delete
	rsync /etc/hbase/conf.edh root@$node:/etc/hbase -avz --delete
	rsync /etc/zookeeper/conf.edh root@$node:/etc/zookeeper -avz --delete
done
