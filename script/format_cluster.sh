#!/bin/sh

if [ `id -u` -ne 0 ]; then
   echo "[ERROR]:Must run as root";   exit 1
fi


CONFIG_PATH=/etc/edh
NODES_FILE=$CONFIG_PATH/nodes.csv

echo "ReCreate local dir in namenode ..."
rm -rf /hadoop/dfs
mkdir -p /hadoop/dfs/{name,namesecondary} 
chown -R hdfs:hdfs /hadoop/dfs && chmod -R 700 /hadoop/dfs/

myid=0
for server in `cat $NODES_FILE` ;do
	myid=`expr $myid + 1`
	echo -e "\nReCreate local dir and init zookeeper in $server ..."

	ssh -q root@$server  "
		rm -rf /hadoop/dfs /var/lib/zookeeper
		mkdir -p /hadoop/dfs/data
		chown -R hdfs:hdfs /hadoop/dfs && chmod -R 700 /hadoop/dfs/
		
		mkdir /var/lib/zookeeper
		chown -R zookeeper:zookeeper /var/lib/zookeeper && chmod -R 700 /var/lib/zookeeper
		service zookeeper-server stop
		service zookeeper-server init --myid=$myid
	"
done

