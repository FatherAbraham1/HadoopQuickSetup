#!/bin/sh

if [ $# -lt 1 ]; then
  echo "Usage: hdfs-cluster.sh start|stop|restart|status"
  exit 1
fi

CONFDIR=/etc/edh/conf

action=$1

if [ -s $CONFDIR/namenode ] ;then
	mussh -m -u -b -t 6 -H $CONFDIR/namenode -c "service hadoop-hdfs-namenode $action"
	echo "Done for Namenode $action."
	echo ""
fi


if [ -s $CONFDIR/datanodes ] ;then
	mussh -m -u -b -t 6 -H $CONFDIR/datanodes -c "service hadoop-hdfs-datanode $action"
	echo "Done for Datanode(s) $action."
	echo ""
fi


if [ -s $CONFDIR/secondary_namenode ] ;then
	mussh -m -u -b -t 6 -H $CONFDIR/secondary_namenode -c "service hadoop-hdfs-secondarynamenode $action"
	echo "Done for Secondary Namnode(s) $action."
	echo ""
fi


