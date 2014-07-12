#!/bin/sh

if [ $# -lt 1 ]; then
  echo "Usage: yarn-cluster.sh start|stop|restart|status"
  exit 1
fi

CONFDIR=/etc/edh/conf

action=$1

#start historyserver
pssh -P -i -h $CONFDIR/historyserver "service hadoop-mapreduce-historyserver $action > /dev/null"
echo "Done for HistroyServer $action."
echo ""

#start nodemanager
pssh -P -i -h $CONFDIR/nodemanager "service hadoop-yarn-nodemanager $action"
echo "Done for NodeManager $action."
echo ""

#start resourcemanager
pssh -P -i -h $CONFDIR/resourcemanagers "service hadoop-yarn-resourcemanager $action"
echo "Done for ResourceManager(s) $action."
echo ""

