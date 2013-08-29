if [ `id -u` -ne 0 ]; then
   echo "must run as root"
   exit 1
fi

echo "[INFO]:format hadoop cluster"

NODES_FILE="/etc/edh/nodes.csv"
if [ -f $NODES_FILE ]; then
    	NODES_LIST="`cat $NODES_FILE`"
else
	echo "ERROR: Can not found role configuration file $NODES_FILE"
	exit 1
fi

myid=0
for server in $NODES_LIST ;do
	myid=`expr $myid + 1`

	echo "[INFO]:remove hdfs local dir in $server"
	echo "[INFO]:init zookeeper in $server: myid=$myid"

	ssh -q root@$server  "
		rm -rf /hadoop/dfs /var/lib/zookeeper
		mkdir -p /hadoop/dfs/{name,data,namesecondary} 
		chown -R hdfs:hdfs /hadoop/dfs && chmod -R 700 /hadoop/dfs/
		
		mkdir /var/lib/zookeeper
		chown -R zookeeper:zookeeper /var/lib/zookeeper && chmod -R 700 /var/lib/zookeeper
		service zookeeper-server init --myid=$myid
	"
done

echo "[INFO]:format namenode"
su -s /bin/bash hdfs -c 'yes Y | hadoop namenode -format >> /tmp/nn.format.log 2>&1'

service hadoop-hdfs-namenode start

echo "[INFO]:hadoop fs: mkdir chmod chown"

su -s /bin/bash hdfs -c 'hadoop fs -chmod 755 /'
while read dir user group perm
do
   su -s /bin/bash hdfs -c "hadoop fs -mkdir $dir && hadoop fs -chmod $perm $dir && hadoop fs -chown $user:$group $dir"
     echo "[INFO]: ."
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

echo "[INFO]:format hadoop finish!"

