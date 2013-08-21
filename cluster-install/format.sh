if [ `id -u` -ne 0 ]; then
   echo "must run as root"
   exit 1
fi

echo "[INFO]:format hadoop cluster"

if [ -f /etc/edh/role.csv ]; then
    	NODELIST="`cat /etc/edh/role.csv | sed 's/,.*//g'`"
else
	echo "ERROR: Can not found role configuration file /etc/edh/role.csv"
	exit 1
fi

sh start.sh stop

myid=0
for server in $NODELIST ;do
	myid=`expr $myid + 1`

	echo "[INFO]:remove hdfs local dir in $server"
	echo "[INFO]:init zookeeper in $server: myid=$myid"

	ssh -q root@$server  "
		rm -rf /hadoop/dfs /var/lib/zookeeper
		mkdir -p /hadoop/dfs/{name,data,namesecondary} 
		chown -R hdfs:hdfs /hadoop/dfs && chmod -R 755 /hadoop/dfs/
		
		mkdir /var/lib/zookeeper
		chown -R zookeeper:zookeeper /var/lib/zookeeper && chmod -R 755 /var/lib/zookeeper
		service zookeeper-server init --myid=$myid
	"
done

echo "[INFO]:format namenode"
su -s /bin/bash hdfs -c 'yes Y | hadoop namenode -format >> /tmp/nn.format.log 2>&1'

service hadoop-hdfs-namenode start

echo "[INFO]:hadoop fs: mkdir chmod chown"

su -s /bin/bash hdfs -c "hadoop fs -chmod a+rw /"
while read dir user group perm
do
   su -s /bin/bash hdfs -c "hadoop fs -mkdir $dir && hadoop fs -chmod $perm $dir && hadoop fs -chown $user:$group $dir"
     echo "[INFO]: ."
done << EOF
/hbase hbase hadoop 755
/tmp hdfs hadoop 1777 
/tmp/hadoop-yarn mapred mapred 777
/var hdfs hadoop 755 
/var/log yarn mapred 1775 
/var/log/hadoop-yarn/apps yarn mapred 1777
/yarn/apps yarn mapred 1777
/user hdfs hadoop 777
/user/root root hadoop 755
/user/hive hive hadoop 775
/user/hive/warehouse hive hadoop 775
/user/history mapred hadoop 1777 
EOF

echo "[INFO]:format hadoop finish!"

