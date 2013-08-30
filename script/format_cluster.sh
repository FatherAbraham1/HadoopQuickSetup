#!/bin/sh

if [ `id -u` -ne 0 ]; then
   echo "[ERROR]:Must run as root"
   exit 1
fi

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

	echo "Remove hdfs local dir in $server ..."
	echo "Init zookeeper in $server: myid=$myid ..."

	ssh -q root@$server  "
		rm -rf /hadoop/dfs /var/lib/zookeeper
		mkdir -p /hadoop/dfs/{name,data,namesecondary} 
		chown -R hdfs:hdfs /hadoop/dfs && chmod -R 700 /hadoop/dfs/
		
		mkdir /var/lib/zookeeper
		chown -R zookeeper:zookeeper /var/lib/zookeeper && chmod -R 700 /var/lib/zookeeper
		service zookeeper-server init --myid=$myid
	"
done

