if [ -f /etc/edh/role.csv ]; then
    	NODELIST="`cat /etc/edh/role.csv | sed 's/,.*//g'`"
else
	echo "ERROR: Can not found role configuration file /etc/edh/role.csv"
	exit 1
fi

echo "[INFO]:service hadoop $1"

for node in $NODELIST ;do
        ssh root@$node  "
		for x in hadoop-hdfs-namenode hadoop-hdfs-datanode hadoop-yarn-resourcemanager hadoop-yarn-nodemanager hbase-master hbase-regionserver hive-metastore hive-server2 zookeeper-server; do  service \$x $1 ; done
	"
done

