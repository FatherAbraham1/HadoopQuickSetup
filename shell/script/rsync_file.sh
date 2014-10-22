#!/bin/sh

HOSTNAME=`hostname`
EDH_PATH=/etc/edh
NODES_FILE=$EDH_PATH/conf/nodes
ZK_HOSTNAME=`cat $NODES_FILE |tr '\n' ','|  sed 's/,$//'`
SLAVES=`cat $NODES_FILE`

echo "[INFO]:copy hadoop template conf"

for srv in hadoop hbase hive zookeeper ; do
	\cp ${EDH_PATH}/template/${srv}/* /etc/${srv}/conf/
done

chmod 755 /etc/hadoop/conf/*.sh

echo "[INFO]:replace hadoop conf"
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/core-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/hdfs-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/mapred-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/yarn-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hive/conf/hive-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hbase/conf/hbase-site.xml
#sed -i "s|localhost|$SLAVES|g" /etc/hadoop/conf/slaves
#sed -i "s|localhost|$SLAVES|g" /etc/hbase/conf/regionservers
sed -i "s|zkhost|$ZK_HOSTNAME|g" /etc/hbase/conf/hbase-site.xml

sh /etc/edh/syn.sh /etc/hadoop/conf /etc/hadoop
sh /etc/edh/syn.sh /etc/hive/conf /etc/hive
sh /etc/edh/syn.sh /etc/hbase/conf /etc/hbase
sh /etc/edh/syn.sh /etc/zookeeper/conf /etc/zookeeper

chmod 755 ${EDH_PATH}/template/postgresql-9.1-901.jdbc4.jar
sh /etc/edh/syn.sh ${EDH_PATH}/template/postgresql-9.1-901.jdbc4.jar /usr/lib/hive/lib/postgresql-jdbc.jar

