#!/bin/sh

if [ $# -lt 1 ]; then
  echo "Usage: cluster.sh start|stop|restart|status"
  exit 1
fi

action=$1

if [ $action == "start" ]; then
	sh cluster/hdfs-cluster.sh $action
	sh cluster/yarn-cluster.sh $action
	sh cluster/hive-cluster.sh $action
	sh cluster/zookeeper-cluster.sh $action
	sh cluster/hbase-cluster.sh $action
else 
	sh cluster/yarn-cluster.sh $action
	sh cluster/hive-cluster.sh $action
	sh cluster/hbase-cluster.sh $action
	sh cluster/zookeeper-cluster.sh $action
	sh cluster/hdfs-cluster.sh $action
fi

