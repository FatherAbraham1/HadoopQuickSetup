#!/bin/sh

if [ $# -lt 1 ]; then
  echo "Usage: hdfs-cluster.sh start|stop|restart|status"
  exit 1
fi

CONFDIR=/etc/edh/conf

action=$1

if [ -s $CONFDIR/namenode ] ;then
	pssh -P -i -h $CONFDIR/namenode "service hadoop-hdfs-namenode $action"
	echo "Done for Namenode $action."
	echo ""
fi


if [ -s $CONFDIR/datanodes ] ;then
	pssh -P -i -h $CONFDIR/datanodes "service hadoop-hdfs-datanode $action"
	echo "Done for Datanode(s) $action."
	echo ""
fi


if [ -s $CONFDIR/secondary_namenode ] ;then
	pssh -P -i -h $CONFDIR/secondary_namenode "service hadoop-hdfs-secondarynamenode $action"
	echo "Done for Secondary Namnode(s) $action."
	echo ""
fi


