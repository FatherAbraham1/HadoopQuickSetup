#!/bin/sh

if [ `id -u` -ne 0 ]; then
   echo "[ERROR]:Must run as root";   exit 1
fi


CONFIG_PATH=/etc/edh/conf
NODES_FILE=$CONFIG_PATH/nodes

echo "rmove local dir in all cluster nodes"
rm -rf /hadoop/dfs
mkdir -p /hadoop/dfs/{name,namesecondary} 
chown -R hdfs:hdfs /hadoop/dfs && chmod -R 700 /hadoop/dfs/

myid=0
for server in `cat $NODES_FILE` ;do
	myid=`expr $myid + 1`
	echo -e "\ninit zookeeper in $server ..."

	ssh -q root@$server  "
		rm -rf /hadoop/dfs /var/lib/zookeeper
		mkdir -p /hadoop/dfs/data
		chown -R hdfs:hdfs /hadoop/dfs && chmod -R 700 /hadoop/dfs/

		#http://archive.cloudera.com/cdh4/cdh/4/hadoop/hadoop-project-dist/hadoop-hdfs/ShortCircuitLocalReads.html
		rm -rf /var/run/hadoop-hdfs/
		mkdir -p /var/run/hadoop-hdfs/
		chown -R hdfs:hdfs /var/run/hadoop-hdfs/
		
		mkdir /var/lib/zookeeper
		chown -R zookeeper:zookeeper /var/lib/zookeeper && chmod -R 700 /var/lib/zookeeper
		service zookeeper-server stop
		service zookeeper-server init --myid=$myid
	"
done


echo -e "\n[INFO]:Format hadoop cluster"

#ps -ef|grep zookeeper|grep QuorumPeerMain|awk '{print $2}'|xargs kill -9

su -s /bin/bash hdfs -c 'yes Y | hadoop namenode -format'

service hadoop-hdfs-namenode start
sleep 10

echo "Create hdfs dir ..."
su -s /bin/bash hdfs -c 'hadoop fs -chmod 755 /'
while read dir user group perm
do
   	su -s /bin/bash hdfs -c "hadoop fs -mkdir $dir && hadoop fs -chmod $perm $dir && hadoop fs -chown $user:$group $dir"
    	echo "[INFO]:mkdir $dir ."
done << EOF
/hbase hbase hadoop 755
/tmp hdfs hadoop 1777 
/yarn/apps yarn mapred 1777
/user hdfs hadoop 777
/user/root root hadoop 755
/user/hive hive hadoop 775
/user/hive/warehouse hive hadoop 1777
/user/history yarn hadoop 1777
/user/history/done mapred hadoop 750
/user/history/done_intermediate mapred hadoop 1777 
EOF
