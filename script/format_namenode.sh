#!/bin/sh

if [ `id -u` -ne 0 ]; then
   echo "[ERROR]:Must run as root";  exit 1
fi

echo "[INFO]:Format hadoop cluster"

if ! service hadoop-hdfs-namenode status >/dev/null 2>&1; then
	service hadoop-hdfs-namenode start
fi

#ps -ef|grep zookeeper|grep QuorumPeerMain|awk '{print $2}'|xargs kill -9

echo "Format namenode ..."
su -s /bin/bash hdfs -c 'yes Y | hadoop namenode -format >> /tmp/nn.format.log 2>&1'
sleep 3

echo "Create hdfs file ..."
su -s /bin/bash hdfs -c 'hadoop fs -chmod 755 /'
while read dir user group perm
do
   su -s /bin/bash hdfs -c "hadoop fs -mkdir $dir && hadoop fs -chmod $perm $dir && hadoop fs -chown $user:$group $dir"
     echo "[INFO]:."
done << EOF
/hbase hbase hadoop 755
/tmp hdfs hadoop 1777 
/tmp/logs yarn hadoop 1777
/user hdfs hadoop 777
/user/root root hadoop 755
/user/hive hive hadoop 775
/user/hive/warehouse hive hadoop 775
/user/history yarn hadoop 1777
/user/history/done mapred hadoop 750
/user/history/done_intermediate mapred hadoop 1777 
EOF

echo "Format hadoop finish ..."

