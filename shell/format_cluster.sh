#!/bin/sh

if [ `id -u` -ne 0 ]; then
   echo "[ERROR]:Must run as root";   exit 1
fi

CONFIG_PATH=/etc/edh/conf
NODES_FILE=$CONFIG_PATH/nodes

echo -e "\n[INFO]:Format hadoop cluster"

#ps -ef|grep zookeeper|grep QuorumPeerMain|awk '{print $2}'|xargs kill -9

su -s /bin/bash hdfs -c 'yes Y | hadoop namenode -format' 

service hadoop-hdfs-namenode start
sleep 10

echo "[INFO]:create hdfs dir ..."
su -s /bin/bash hdfs -c 'hadoop fs -chmod 755 /'

while read dir user group perm
do
   	su -s /bin/bash hdfs -c "hadoop fs -mkdir -p $dir ; hadoop fs -chmod -R $perm $dir ; hadoop fs -chown $user:$group $dir"
    	echo "[INFO]:mkdir $dir"
done << EOF
/tmp hdfs hadoop 1777 
/yarn/apps yarn mapred 1777
/user hdfs hadoop 777
/user/root root hadoop 755
/user/hive hive hadoop 777
/user/hive/warehouse hive hadoop 1777
/user/history yarn hadoop 1777
/user/history/done mapred hadoop 750
/user/history/done_intermediate mapred hadoop 1777 
/hbase hbase hadoop 755

EOF
