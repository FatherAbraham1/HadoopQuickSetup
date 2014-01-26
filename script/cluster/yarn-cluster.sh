#!/bin/sh

if [ $# -lt 1 ]; then
  echo "Usage: yarn-cluster.sh start|stop|restart|status"
  exit 1
fi

CONFDIR=/etc/edh/conf

action=$1

#start historyserver
mussh -m -u -b -t 6 -H $CONFDIR/historyserver -c "service hadoop-mapreduce-historyserver $action"
echo "Done for HistroyServer $action."
echo ""

#start nodemanager
mussh -m -u -b -t 6 -H $CONFDIR/nodemanager -c "service hadoop-yarn-nodemanager $action"
echo "Done for NodeManager $action."
echo ""

#start resourcemanager
mussh -m -u -b -t 6 -H $CONFDIR/resourcemanagers -c "service hadoop-yarn-resourcemanager $action"
echo "Done for ResourceManager(s) $action."
echo ""

