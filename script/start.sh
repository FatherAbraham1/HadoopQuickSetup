
NODES_FILE="/etc/edh/nodes.csv"
if [ -f $NODES_FILE ]; then
    	NODES_LIST="`cat $NODES_FILE`"
else
	echo "ERROR: Can not found role configuration file $NODES_FILE"
	exit 1
fi

echo "[INFO]:service hadoop $1"

for node in $NODES_LIST ;do
        ssh root@$node  "
		for x in hadoop-hdfs-namenode hadoop-hdfs-datanode hadoop-yarn-resourcemanager hadoop-yarn-nodemanager hbase-master hbase-regionserver hive-metastore hive-server2 zookeeper-server; do 
    			service \$x $1 ;
		 done
	"
done

